require 'open-uri'
require 'json'

require 'rom'

require './lib/github_adapter'

class Repo
  attr_accessor :id, :name, :stars
end

rom = ROM::Environment.setup(github_rom_repos: 'github://orgs/rom-rb/repos') do
  schema do
    base_relation :repos do
      repository :github_rom_repos

      attribute :id,       Integer
      attribute :name,     String
      attribute :watchers, Integer
    end
  end

  mapping do
    relation :repos do
      model Repo

      map :id, :name
      map :stars, from: :watchers
    end
  end

end

repos = rom[:repos].restrict { |r| r.watchers.gt(10) }.sort_by(:watchers)

repos.each do |repo|
  puts "name #{repo.name} with #{repo.stars} stars"
end
