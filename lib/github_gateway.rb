require 'rom/support/axiom/adapter'
require 'rom/support/axiom/adapter/memory'

module Axiom
  module Adapter

    class Github
      extend Adapter

      uri_scheme :github

      attr_reader :source, :schema

      def initialize(uri)
        @source = "#{uri.host}#{uri.path}"
        @schema = {}
      end

      def [](name)
        @schema[name]
      end

      def []=(name, relation)
        @schema[name] = Gateway.new(relation, self)
      end

      def read(relation)
        names = relation.header.map(&:name).map(&:to_s)
        json.map { |data| data.values_at(*names) }
      end

      def json
        JSON.parse(open("https://api.github.com/#{source}").read)
      end
    end

    class Gateway < Relation
      include Relation::Proxy

      attr_reader :adapter

      def initialize(relation, adapter)
        @relation = relation
        @adapter  = adapter
      end

      def each(&block)
        tuples.each(&block)
      end

      private

      def tuples
        if materialized?
          relation
        else
          Relation.new(header, adapter.read(relation))
        end
      end
    end

  end
end
