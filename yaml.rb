require 'rom'

require './lib/yaml_adapter'

rom = ROM::Environment.setup(yaml: 'yaml://tmp/sample.yml')

rom.schema do
  base_relation :users do
    repository :yaml

    attribute :id,   Integer
    attribute :name, String
  end
end

class User
  attr_accessor :id, :name
end

rom.mapping do
  users do
    model User
    map :id, :name
  end
end

jane = rom[:users].restrict(name: 'Jane').sort_by(:name).one

puts "id #{jane.id} name #{jane.name}"
