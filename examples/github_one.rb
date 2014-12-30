require './lib/github_adapter'
require 'anima'

class Repo
  include Anima.new(:id, :name, :stars)
end

rom = ROM.setup(github_rom_org: 'github://orgs/rom-rb') do
  schema do
    base_relation :repos do
      repository :github_rom_org

      attribute 'id'
      attribute 'name'
      attribute 'watchers'
    end
  end

  relation(:repos) do
    def most_popular
      project(*header)
        .restrict { |repo| repo['watchers'] > 10 }
        .order('watchers')
        .reverse
    end
  end

  mappers do
    define(:repos, symbolize_keys: true) do
      model Repo
      attribute :id
      attribute :name
      attribute :stars, from: 'watchers'
    end
  end
end

rom.read(:repos).most_popular.each do |repo|
  puts "name #{repo.name} with #{repo.stars} stars"
end
