require 'equivalent-xml/proxy/base'

module EquivalentXml
  module Proxy
    class Nokogiri < Base
      def self.parse(source)
        ::Nokogiri::XML(source)
      end
      
      def has_attributes?
        @thing.respond_to?(:attribute_nodes)
      end
      
      def has_children?
        @thing.respond_to?(:children)
      end
      
      def is_nodeset?
        @thing.is_a?(::Nokogiri::XML::NodeSet)
      end
      
      def is_character_data?
        @thing.is_a?(::Nokogiri::XML::CharacterData)
      end

      def as_document
        self.class.proxy(::Nokogiri::XML(@thing))
      end
      
      def as_fragment
        content = is_nodeset? ? @thing.children.collect(&:clone) : @thing
        self.class.proxy(::Nokogiri::XML.fragment(content).children)
      end
      
      def attributes
        self.class.proxy(@thing.attribute_nodes)
      end
      
      def namespace_uri
        @thing.namespace.nil? ? nil : @thing.namespace.href
      end
      
      def node_type
        @thing.respond_to?(:node_type) ? @thing.node_type : 0
      end
      
      def root
        @thing.respond_to?(:document) ? @thing.document.root : nil
      end
      
      def ignore_content?(list, opts={})
        list.each do |selector|
          return true if @thing.document.css(selector).include?(@thing)
        end
        return false
      end

      def element_index
        @thing.parent.elements.index(@thing)
      end
    end
  end
end
