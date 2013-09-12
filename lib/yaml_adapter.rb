require 'rom/support/axiom/adapter'
require 'yaml'

module Axiom
  module Adapter

    class Yaml
      extend Adapter

      uri_scheme :yaml

      def initialize(uri)
        @path   = "#{uri.host}#{uri.path}"
        @schema = {}
        reload
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

      def insert(relation, tuples)
        @data[relation.name] ||= []
        tuples.each do |tuple|
          @data[relation.name] << attributes(relation.header, tuple)
        end
        write
        reload
      end

      private

      def attributes(header, tuple)
        Hash[header.map(&:name).zip(tuple)]
      end

      def write
        File.open(@path, 'w') { |f| f << YAML.dump(@data) }
      end

      def reload
        @data = File.exist?(@path) ? YAML.load_file(@path) : {}
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

      def insert(tuples)
        adapter.insert(relation, tuples)
        self
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
