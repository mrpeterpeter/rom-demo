require 'rom'
require 'rom/adapter/memory/dataset'

require 'faraday'
require 'json'

module ROM

  class GithubAdapter < Adapter
    attr_reader :resources

    class Resource
      include Enumerable

      attr_reader :connection, :path

      def initialize(connection, path)
        @connection = connection
        @path = path
      end

      def each(&block)
        JSON.parse(connection.get(path).body).each(&block)
      end
    end

    class Dataset < Adapter::Memory::Dataset
      include Charlatan.new(:data, kind: Array)

      def self.build(*args, header)
        new(Resource.new(*args), header)
      end

      def initialize(data, header)
        super
        @header = header
      end
    end

    def self.schemes
      [:github]
    end

    def initialize(uri, options = {})
      super
      @connection = Faraday.new(url: "https://api.github.com/#{uri.host}#{uri.path}")
      @resources = {}
    end

    def [](name)
      resources.fetch(name)
    end

    def dataset(name, header)
      resources[name] = Dataset.build(connection, name.to_s, header)
    end

    def dataset?(name)
      resources.key?(name)
    end
  end

end
