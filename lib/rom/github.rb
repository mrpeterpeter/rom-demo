require 'faraday'
require 'json'

require 'transproc/all'

module ROM
  module Github
    class Dataset
      include Enumerable

      attr_reader :connection, :path, :row_proc

      def initialize(connection, path)
        @connection = connection
        @path = path.to_s
        @row_proc = Transproc(:hash_recursion, Transproc(:symbolize_keys))
      end

      def each(&block)
        JSON.parse(connection.get(path).body).each do |row|
          yield(row_proc[row])
        end
      end
    end

    class Relation < ROM::Relation
      forward :select, :sort_by, :reverse, :take
    end

    class Repository < ROM::Repository
      attr_reader :resources

      def initialize(path)
        @connection = Faraday.new(url: "https://api.github.com/#{path}")
        @resources = {}
      end

      def [](name)
        resources.fetch(name)
      end

      def dataset(name)
        resources[name] = Dataset.new(connection, name)
      end

      def dataset?(name)
        resources.key?(name)
      end
    end
  end
end

ROM.register_adapter(:github, ROM::Github)
