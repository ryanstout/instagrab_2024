require "sqlite3"

class Database
  attr_reader :db

  def initialize
    # Create a SQLite3 database in memory
    @db = SQLite3::Database.new "db.sqlite3"
    @db.results_as_hash = true

    # Create a table with specified fields
    @db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY,
        email_prefix TEXT,
        email TEXT,
        full_name TEXT,
        password TEXT,
        state INTEGER DEFAULT 0,
        proxy TEXT
      );
    SQL

    # For users,
    # state 0 = no email created
    # state 1 = email being created
    # state 2 = email created, ig being created
    # state 3 = email created, ig created

    @db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS profiles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_name TEXT NOT NULL,
        pulled BOOLEAN DEFAULT FALSE
      );
    SQL

    @db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS proxy_pool (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        proxy TEXT NOT NULL,
        state INTEGER DEFAULT 0
      );
    SQL

    # For proxy_pool, state 0 is unassigned, 1 is being assigned, 2 is assigned
    # (If things fail to get setup, we can reassign 1's back to 0)
  end

  # We assign a proxy to a user when they are created, we want to always use that proxy
  def add_user(email_prefix, email, full_name, password, proxy)
    @db.execute("INSERT INTO users (email_prefix, email, full_name, password, state, proxy) VALUES (?, ?, ?, ?, ?, ?)", [email_prefix, email, full_name, password, 1, proxy])
  end

  def signed_up(email, proxy)
    @db.execute("UPDATE users SET state=2 WHERE email = ?", [email])

    # Mark the proxy as assigned
    @db.execute("UPDATE proxy_pool SET state = 2 WHERE proxy = ?", [proxy])
  end

  def add_proxy(proxy)
    @db.execute("INSERT INTO proxy_pool (proxy, state) VALUES (?, ?)", [proxy, 0])
  end

  # Grab a user who hasn't done the instagram registration
  # Sets ig_registration_active to true
  def get_ig_unregistered_user
    begin
      # Start an exclusive transaction to ensure atomicity
      @db.transaction(SQLite3::Transaction::EXCLUSIVE) do
        # First, determine the ID of the row to update
        user = @db.get_first_value("SELECT id FROM users WHERE state=1 ORDER BY id ASC LIMIT 1")

        # Perform the update if an ID was found
        if user && user.size > 0
          user_id = user["user_id"]
          @db.execute("UPDATE users SET state=2 WHERE id = ?", user_id)

          # Immediately fetch the updated row
          result = @db.execute("SELECT * FROM users WHERE id = ?", user_id)

          return result[0]
        else
          puts "No inactive users found to update."
          return nil
        end
      end
    rescue SQLite3::BusyException => e
      puts "Database is locked, transaction couldn't be completed: #{e.message}"
      raise e
    rescue SQLite3::SQLException => e
      puts "An SQL error occurred: #{e.message}"
      raise e
    rescue => e
      puts "An unexpected error occurred: #{e.message}"
      raise e
    end
  end
end

if __FILE__ == $0
  # add_user(db, "test", "
end
