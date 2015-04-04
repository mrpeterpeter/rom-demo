require 'rom-sql'

ROOT = Pathname(__FILE__).join("../..")
setup = ROM.setup(:sql, "sqlite://#{ROOT}/db/sqlite.db")

conn = setup.default.connection

conn.drop_table?(:applications)
conn.drop_table?(:slots)

conn.create_table(:applications) do
  primary_key :id
  Integer :slot_id
  String :name
end

conn.create_table(:slots) do
  primary_key :id
  String :name
end

conn[:slots].insert(name: 'Primary')
conn[:slots].insert(name: 'Secondary')

conn[:applications].insert(slot_id: 2, name: 'Secondary App')
conn[:applications].insert(slot_id: 1, name: 'Primary App')
