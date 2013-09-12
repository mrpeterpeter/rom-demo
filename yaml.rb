require 'rom'
require 'fileutils'

require './lib/yaml_adapter'

FileUtils.rm('db/sample.yml') if File.exist?('db/sample.yml')

rom = ROM::Environment.setup(yaml: 'yaml://db/sample.yml')

rom.schema do
  base_relation :users do
    repository :yaml

    attribute :id,   Integer
    attribute :name, String
  end
end

class User
  attr_accessor :id, :name

  def initialize(attributes)
    attributes.each { |name, value| send("#{name}=", value) }
  end
end

rom.mapping do
  users do
    model User
    map :id, :name
  end
end

users = rom[:users]

users.insert(User.new(id: 1, name: 'Jane'))
users.insert(User.new(id: 2, name: 'John'))

jane = users.restrict(name: 'Jane').sort_by(:name).one

puts "id #{jane.id} name #{jane.name}"

rom.session do |session|
  jane = session[:users].restrict(name: 'Jane').sort_by(:name).one
  jane.name = 'Jane Doe'

  session[:users].save(jane)

  session.flush
end

john = User.new(id: 2, name: 'John')

users.delete(john)

puts "user names: #{users.map(&:name).inspect}"
