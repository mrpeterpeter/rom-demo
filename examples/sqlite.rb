require 'anima'

require Pathname(__FILE__).expand_path.join('../../lib/db_setup')

class Application
  include Anima.new :id, :name, :slot

  class Slot
    include Anima.new :id, :name
  end
end

ROM.relation(:applications) do
  many_to_one :slots, key: :slot_id

  def with_slot
    select(:id, :name).association_join(:slots, select: [:id, :name])
  end
end

ROM.mappers do
  define :applications do
    model Application

    attribute :id
    attribute :name

    wrap :slot, prefix: :slots do
      model Application::Slot

      attribute :id
      attribute :name
    end
  end
end

rom = ROM.finalize.env

puts rom.read(:applications).with_slot.to_a.inspect
# [#<Application id=1 name="Secondary App" slot=#<Application::Slot id=2 name="Secondary">>, #<Application id=2 name="Primary App" slot=#<Application::Slot id=1 name="Primary">>]
