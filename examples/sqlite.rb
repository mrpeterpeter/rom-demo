require Pathname(__FILE__).expand_path.join('../../lib/db_setup')

require 'ostruct'
require 'rom'
require 'rom/support/axiom/adapter/sqlite3'

class Application
  include Equalizer.new :id, :name

  attr_accessor :id, :name
end

class Slot
  include Equalizer.new :id, :name, :applications

  attr_accessor :id, :name, :applications
end

rom = ROM::Environment.setup(sqlite: "sqlite3://#{ROOT}/db/sqlite.db") do
  schema do
    base_relation :applications do
      repository :sqlite

      attribute :id, Integer, rename: :application_id
      attribute :slot_id, Integer
      attribute :name, String, rename: :application_name

      key :id
    end

    base_relation :slots do
      repository :sqlite

      attribute :id, Integer, rename: :slot_id
      attribute :name, String, rename: :slot_name

      key :id
    end
  end

  mapping do
    relation :applications do
      model Application

      map :id, from: :application_id
      map :name, from: :application_name
    end

    relation :slots do
      model Slot

      map :id, from: :slot_id
      map :name, from: :slot_name
    end
  end
end

slots = rom[:slots]
applications = rom[:applications]

puts slots.
  join(applications).
  group(:applications => applications.project([:application_id, :application_name])).
  project([:slot_id, :slot_name, :applications]).
  to_a.inspect
