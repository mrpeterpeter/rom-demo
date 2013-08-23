require 'open-uri'
require 'json'
require 'ostruct'

require 'rom-relation'
require 'rom-mapper'

require './lib/github_gateway'

rom = ROM::Environment.coerce(github_rom_repos: 'github://orgs/rom-rb/repos')

rom.schema do
  base_relation :repos do
    repository :github_rom_repos

    attribute :id,   Integer
    attribute :name, String
  end
end

class Repo
  attr_accessor :id, :name
end

rom.mapping do
  repos do
    model Repo

    map :id, :name
  end
end

puts rom[:repos].to_a.inspect
