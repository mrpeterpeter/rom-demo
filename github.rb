require 'open-uri'
require 'json'

require 'rom-relation'
require 'rom-mapper'

require './lib/github_gateway'

rom = ROM::Environment.coerce(github_rom_repos: 'github://orgs/rom-rb/repos')

rom.schema do
  base_relation :repos do
    repository :github_rom_repos

    attribute :id,       Integer
    attribute :name,     String
    attribute :watchers, Integer
  end
end

class Repo
  attr_accessor :id, :name, :stars
end

rom.mapping do
  repos do
    model Repo

    map :id, :name
    map :watchers, to: :stars
  end
end

repos = rom[:repos].restrict { |r| r.stars.gt(10) }.sort_by(:stars)

repos.each do |repo|
  puts "name #{repo.name} with #{repo.stars} stars"
end
