require 'equivalent-xml/node_type'
Dir[File.expand_path('../equivalent-xml/proxy/*',__FILE__)].each { |file| require file }

module EquivalentXml
  class << self
    
    # Determine if two XML documents or nodes are equivalent
    #
    # @param [Node, NodeSet] node_1 The first top-level XML node to compare
    # @param [Node, NodeSet] node_2 The secton top-level XML node to compare
    # @param [Hash] opts Options that determine how certain comparisons are evaluated
    # @option opts [Boolean] :element_order (false) Child elements must occur in the same order to be considered equivalent
    # @option opts [Boolean] :normalize_whitespace (true) Collapse whitespace within Text nodes before comparing
    # @option opts [String, Array] :ignore_content (nil) CSS selector(s) of nodes for which the content (text and child nodes) should be ignored when comparing for equivalence
    # @yield [n1,n2,result] The two nodes currently being evaluated, and whether they are considered equivalent. The block can return true or false to override the default evaluation
    # @return [Boolean] true or false
    def equivalent?(node_1, node_2, opts={}, &block)
      processor = processor_for(node_1, node_2)
      processor.equivalent?(node_1, node_2, opts, &block)
    end

    private
    def proxy_classes
      ObjectSpace.each_object(Proxy::Base.singleton_class).to_a.reject { |klass| not klass.present? }
    end
    
    def processor_for(*args)
      proxies = args.collect do |thing| 
        driver = thing.class.name.split(/::/).first.to_sym
        proxy_classes.find { |klass| klass.driver_name == driver }
      end
      proxies = proxies.compact.uniq
      if proxies.length > 1
        raise ArgumentError, "Cannot mix node types: #{proxies.collect { |d| d.driver_name.inspect }.join(', ')}"
      end
      Processor.new(proxies.first || proxy_classes.first)
    end
  end
  
  class Processor
    DEFAULT_OPTS = { :ignore_attr_values => false, :element_order => false, :normalize_whitespace => true }

    def initialize(proxy_class)
      @proxy_class = proxy_class
    end
    
    def proxy(obj)
      @proxy_class.proxy(obj)
    end
    
    def equivalent?(node_1, node_2, opts = {}, &block)
      node_1 = proxy(node_1)
      node_2 = proxy(node_2)

      opts = DEFAULT_OPTS.merge(opts)
      if [node_1, node_2].any?(&:is_nodeset?)
        self.compare_nodesets(as_nodeset(node_1, opts), as_nodeset(node_2, opts), opts, &block)
      else
        # Don't let one node to coerced to a DocumentFragment if the other one is a Document
        node_2 = node_2.as_document if node_1.is_document? and !node_2.is_node?
        node_1 = node_1.as_document if node_2.is_document? and !node_1.is_node?
        self.compare_nodes(as_node(node_1), as_node(node_2), opts, &block)
      end
    end

    def compare_nodes(node_1, node_2, opts, &block)
      result = nil
      if [node_1, node_2].any? { |node| not node.is_node? }
        result = node_1.to_s == node_2.to_s
      elsif (node_1.class != node_2.class) or self.same_namespace?(node_1,node_2) == false
        result = false
      else
        case node_1.node_type
        when NodeType::DOCUMENT_NODE
          result = self.compare_documents(node_1,node_2,opts,&block)
        when NodeType::ELEMENT_NODE
          result = self.compare_elements(node_1,node_2,opts,&block)
        when NodeType::ATTRIBUTE_NODE
          result = self.compare_attributes(node_1,node_2,opts,&block)
        when NodeType::CDATA_SECTION_NODE
          result = self.compare_cdata(node_1,node_2,opts,&block)
        when NodeType::TEXT_NODE
          result = self.compare_text(node_1,node_2,opts,&block)
        else
          result = self.compare_children(node_1,node_2,opts,&block)
        end
      end
      if block_given?
        block_result = yield(node_1.thing, node_2.thing, result)
        if block_result.is_a?(TrueClass) or block_result.is_a?(FalseClass)
          result = block_result
        end
      end
      return result
    end

    def compare_documents(node_1, node_2, opts, &block)
      self.equivalent?(node_1.root,node_2.root,opts,&block)
    end
    
    def compare_elements(node_1, node_2, opts, &block)
      (node_1.name == node_2.name) && self.compare_children(node_1,node_2,opts,&block)
    end
    
    def compare_attributes(node_1, node_2, opts, &block)

      attr_names_match = node_1.name == node_2.name

      ignore_attrs = opts[ :ignore_attr_values ]

      if ignore_attrs && (ignore_attrs.empty? || ignore_attrs.include?( node_1.name ))
        attr_names_match
      else
        attr_names_match && (node_1.value == node_2.value)
      end
    end
    
    def compare_text(node_1, node_2, opts, &block)
      if opts[:normalize_whitespace]
        node_1.text.strip.gsub(/\s+/,' ') == node_2.text.strip.gsub(/\s+/,' ')
      else
        node_1.text == node_2.text
      end
    end
    
    def compare_cdata(node_1, node_2, opts, &block)
      node_1.text == node_2.text
    end
    
    def compare_children(node_1, node_2, opts, &block)
      if ignore_content?(node_1, opts)
        # Stop recursion and state a match on the children
        result = true
      else
        nodeset_1 = as_nodeset(node_1.children, opts)
        nodeset_2 = as_nodeset(node_2.children, opts)
        result = self.compare_nodesets(nodeset_1,nodeset_2,opts,&block)
      end
      
      if node_1.has_attributes?
        attributes_1 = node_1.attributes.reject { |a| a.name =~ /^xmlns/ }
        attributes_2 = node_2.attributes.reject { |a| a.name =~ /^xmlns/ }
        result = result && self.compare_nodesets(attributes_1,attributes_2,opts,&block)
      end
      result
    end
    
    def compare_nodesets(nodeset_1, nodeset_2, opts, &block)
      local_set_1 = nodeset_1.dup
      local_set_2 = nodeset_2.dup
      
      if local_set_1.length != local_set_2.length
        return false
      end
    
      local_set_1.each do |search_node|
        found_node = local_set_2.find { |test_node| self.equivalent?(search_node,test_node,opts,&block) }

        if found_node.nil?
          return false
        else
          search_proxy = proxy(search_node)
          found_proxy = proxy(found_node)
          if search_proxy.is_element? and opts[:element_order]
            if search_proxy.element_index != found_proxy.element_index
              return false
            end
          end
          local_set_2.delete(found_node)
        end
      end
      return local_set_2.length == 0
    end

    # Determine if two nodes are in the same effective Namespace
    #
    # @param [Node OR String] node_1 The first node to test
    # @param [Node OR String] node_2 The second node to test
    def same_namespace?(node_1, node_2)
      args = [node_1,node_2]

      # CharacterData nodes shouldn't have namespaces. But in Nokogiri,
      # they do. And they're invisible. And they get corrupted easily.
      # So let's wilfully ignore them. And while we're at it, let's
      # ignore any class that doesn't know it has a namespace.
      if args.all? { |node| not node.is_namespaced? } or 
         args.any? { |node| node.is_character_data? }
           return true
      end
      
      href1 = node_1.namespace_uri || ''
      href2 = node_2.namespace_uri || ''
      return href1 == href2
    end
    
    private
    def as_node(data)
      if data.respond_to?(:node_type)
        return data
      else
        result = data.as_fragment
        if result.root.nil?
          return data
        else
          return result
        end
      end
    end
    
    def as_nodeset(data, opts = {})
      ignore_proc = lambda do |child|
        child.node_type == NodeType::COMMENT_NODE ||
        child.node_type == NodeType::PI_NODE ||
        (opts[:normalize_whitespace] && child.node_type == NodeType::TEXT_NODE && child.text.strip.empty?)
      end

      data = proxy(data)
      
      content = if data.is_nodeset?
        data.reject { |child| ignore_proc.call(proxy(child)) }
      else
        data.as_fragment.reject { |child| ignore_proc.call(proxy(child)) }
      end
      proxy(content)
    end

    def ignore_content?(node, opts = {})
      ignore_list = Array(opts[:ignore_content]).flatten.compact
      return false if ignore_list.empty?

      node.ignore_content?(ignore_list, opts)
    end
  end

end

if defined?(::RSpec::Matchers) or defined?(::Spec::Matchers)
  require 'equivalent-xml/rspec_matchers'
end
