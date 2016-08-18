module EquivalentXml
  module Proxy
    class Oga < Base
      def self.parse(source)
        ::Oga.parse_xml(source)
      end
      
      def initialize(thing)
        super
        if is_namespaced? and has_attributes?
          @thing.attributes.reject! { |a| @thing.namespaces[a.name] and @thing.namespaces[a.name].uri == a.value }
        end
      end

      def has_attributes?
        @thing.respond_to?(:attributes)
      end
      
      def has_children?
        @thing.respond_to?(:children)
      end
      
      def is_nodeset?
        @thing.is_a?(::Oga::XML::NodeSet)
      end
      
      def is_character_data?
        @thing.is_a?(::Oga::XML::CharacterNode)
      end

      def as_document
        self.class.proxy(::Oga.parse_xml(@thing))
      end
      
      def as_fragment
        is_nodeset? ? self : self.class.proxy(::Oga.parse_xml(@thing).children)
      end
      
      def attributes
        self.class.proxy(@thing.attributes)
      end
      
      def namespace_uri
        @thing.namespace.nil? ? nil : @thing.namespace.uri
      end
      
      def node_type
        case @thing
        when ::Oga::XML::Element then NodeType::ELEMENT_NODE
        when ::Oga::XML::Attribute then NodeType::ATTRIBUTE_NODE
        when ::Oga::XML::Text then NodeType::TEXT_NODE
        when ::Oga::XML::Cdata then NodeType::CDATA_SECTION_NODE
        when ::Oga::XML::ProcessingInstruction then NodeType::PI_NODE
        when ::Oga::XML::Comment then NodeType::COMMENT_NODE
        when ::Oga::XML::Document then NodeType::DOCUMENT_NODE
        when ::Oga::XML::Doctype then NodeType::DOCUMENT_TYPE_NODE
        else 0
        end
      end
      
      def root
        @thing.respond_to?(:root_node) ? @thing.root_node.children.first : nil
      end
      
      def ignore_content?(list, opts={})
        list.each do |selector|
          return true if @thing.root_node.css(selector).include?(@thing)
        end
        return false
      end

      def element_index
        @thing.parent.children.select { |n| n.is_a?(::Oga::XML::Element) }.index(@thing)
      end
    end
  end
end
