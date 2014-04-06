require 'do_sqlite3'

DataObjects.logger.set_log('log/do.log', :debug)

ROOT = Pathname(__FILE__).join("../..")

def setup_db
  connection = DataObjects::Connection.new("sqlite3://#{ROOT.join("db/sqlite.db")}")

  connection.create_command('DROP TABLE IF EXISTS "applications"').execute_non_query
  connection.create_command('DROP TABLE IF EXISTS "slots"').execute_non_query

  connection.create_command(<<-SQL.gsub(/\s+/, ' ').strip).execute_non_query
    CREATE TABLE applications (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      slot_id INTEGER NOT NULL,
      name VARCHAR(64)
    )
  SQL

  connection.create_command(<<-SQL.gsub(/\s+/, ' ').strip).execute_non_query
    CREATE TABLE slots (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name VARCHAR(64)
    )
  SQL

  connection.close
end

def seed
  connection = DataObjects::Connection.new("sqlite3://#{ROOT.join("db/sqlite.db")}")

  connection.create_command('INSERT INTO slots VALUES(1, "Primary")').execute_non_query
  connection.create_command('INSERT INTO slots VALUES(2, "Secondary")').execute_non_query

  connection.create_command('INSERT INTO applications VALUES(1, 2, "Secondary App")').execute_non_query
  connection.create_command('INSERT INTO applications VALUES(2, 1, "Primary App")').execute_non_query

  connection.close
end

setup_db
seed
