require 'rom/support/axiom/adapter'
require 'yaml'

module Axiom
  module Adapter

    class Yaml
      extend Adapter

      uri_scheme :yaml

      def initialize(uri)
        @data   = YAML.load_file("#{uri.host}#{uri.path}")
        @schema = {}
      end

      def [](name)
        @schema[name]
      end

      def []=(name, relation)
        @schema[name] = Gateway.new(relation, self)
      end

      def read(relation)
        attributes = relation.header.map(&:name)
        @data[relation.name].map { |hash| hash.values_at(*attributes) }
      end
    end

    class Gateway < Axiom::Relation
      include Axiom::Relation::Proxy

      attr_reader :relation, :adapter

      def initialize(relation, adapter)
        @relation = relation
        @adapter  = adapter
      end

      def each(&block)
        tuples.each(&block)
      end

      private

      def tuples
        if relation.materialized?
          relation
        else
          Relation.new(header, adapter.read(relation))
        end
      end
    end

  end
end
