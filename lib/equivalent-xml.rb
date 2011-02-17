require 'nokogiri'

module EquivalentXml
  
  class << self

    def equivalent?(node_1, node_2, opts = { :element_order => false })
      self.compare_nodes(node_1, node_2, opts)
    end
  
    def compare_nodes(node_1, node_2, opts)
      if node_1.class != node_2.class
        return false
      elsif self.same_namespace?(node_1,node_2) == false
        return false
      elsif node_1.is_a?(Nokogiri::XML::Document)
        return self.compare_documents(node_1,node_2,opts)
      elsif node_1.is_a?(Nokogiri::XML::Element)
        return self.compare_elements(node_1,node_2,opts)
      elsif node_1.is_a?(Nokogiri::XML::Attr)
        return self.compare_attributes(node_1,node_2)
      elsif node_1.is_a?(Nokogiri::XML::CDATA)
        return self.compare_cdata(node_1,node_2)
      elsif node_1.is_a?(Nokogiri::XML::CharacterData)
        return self.compare_text(node_1,node_2)
      else
        return self.compare_children(node_1,node_2,opts)
      end
    end

    def compare_documents(node_1, node_2, opts)
      self.equivalent?(node_1.root,node_2.root,opts)
    end
    
    def compare_elements(node_1, node_2, opts)
      (node_1.name == node_2.name) && self.compare_children(node_1,node_2,opts)
    end
    
    def compare_attributes(node_1, node_2)
      (node_1.name == node_2.name) && (node_1.value == node_2.value)
    end
    
    def compare_text(node_1, node_2)
      node_1.text.strip.gsub(/\s+/,' ') == node_2.text.strip.gsub(/\s+/,' ')
    end
    
    def compare_cdata(node_1, node_2)
      node_1.text == node_2.text
    end
    
    def compare_children(node_1, node_2, opts)
      ignore_proc = lambda do |child|
        child.is_a?(Nokogiri::XML::Comment) ||
        child.is_a?(Nokogiri::XML::ProcessingInstruction) ||
        (child.class == Nokogiri::XML::Text && child.text.strip.empty?)
      end
    
      nodeset_1 = node_1.children.reject { |child| ignore_proc.call(child) }
      nodeset_2 = node_2.children.reject { |child| ignore_proc.call(child) }
      result = self.compare_nodesets(nodeset_1,nodeset_2,opts)
      
      if node_1.respond_to?(:attribute_nodes)
        attributes_1 = node_1.attribute_nodes
        attributes_2 = node_2.attribute_nodes
        result = result && self.compare_nodesets(attributes_1,attributes_2,opts)
      end
      result
    end
    
    def compare_nodesets(nodeset_1, nodeset_2, opts)
      local_set_1 = nodeset_1.dup
      local_set_2 = nodeset_2.dup
      
      if local_set_1.length != local_set_2.length
        return false
      end
    
      local_set_1.each do |search_node|
        found_node = local_set_2.find { |test_node| self.equivalent?(search_node,test_node,opts) }
        if found_node.nil?
          return false
        else
          if search_node.is_a?(Nokogiri::XML::Element) and opts[:element_order]
            if search_node.parent.elements.index(search_node) != found_node.parent.elements.index(found_node)
              return false
            end
          end
          local_set_2.delete(found_node)
        end
      end
      return local_set_2.length == 0
    end

    def same_namespace?(node_1, node_2)
      unless node_1.respond_to?(:namespace) and node_2.respond_to?(:namespace)
        return true
      end
      
      if node_1.namespace.nil? and node_2.namespace.nil?
        return true
      end
    
      href1 = node_1.namespace.nil? ? '' : node_1.namespace.href
      href2 = node_2.namespace.nil? ? '' : node_2.namespace.href
      return href1 == href2
    end
  
  end

end
