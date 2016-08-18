module EquivalentXml
  module Proxy
    class Base
      attr_reader :thing
      
      def self.driver_name
        self.name.split(/::/).last.to_sym
      end

      def self.parse(source)
        raise NameError, "No parsing in the base class."
      end
      
      def self.present?
        begin
          self.parse('<doc/>')
          true
        rescue NameError
          false
        end
      end

      def self.proxy(thing)
        return thing if thing.is_a?(Base)
        self.new(thing)
      end
      
      def dup
        self.class.proxy(@thing.dup)
      end
      
      def initialize(thing)
        @thing = thing
      end

      def is_document?
        self.node_type == NodeType::DOCUMENT_NODE
      end
      
      def is_namespaced?
        @thing.respond_to?(:namespace)
      end
      
      def is_element?
        self.node_type == NodeType::ELEMENT_NODE
      end
      
      def is_node?
        self.node_type > 0
      end
      
      def to_s
        @thing.to_s
      end
      
      def to_xml
        @thing.to_xml
      end

      def method_missing(sym, *args, &block)
        @thing.send(sym, *args, &block)
      end
    end
  end
end
