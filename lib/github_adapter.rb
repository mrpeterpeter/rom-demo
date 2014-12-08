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

      def self.build(*args)
        new(Resource.new(*args))
      end
    end

    def self.schemes
      [:github]
    end

    def initialize(uri)
      super
      @connection = Faraday.new(url: "https://api.github.com/#{uri.host}#{uri.path}")
      @resources = {}
    end

    def [](name)
      @resources[name] ||= Dataset.build(connection, name.to_s)
    end

    def dataset?(name)
      resources.key?(name)
    end

    Adapter.register(self)
  end

end
