$LOAD_PATH << "."

require "active_record"
require "yaml"
require "app/models/base"

namespace :db do
  desc "Create the database"
  task :create do
    puts "Database created"
  end

  desc "Migrate the database"
  task migrate: :environment do
    ActiveRecord::MigrationContext.new("db/migrate/", ActiveRecord::Base.connection.schema_migration).migrate(ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
  end

  desc "Rolls the schema back to the previous version (specify steps w/ STEP=n)"
  task rollback: :environment do
    step = ENV["STEP"] ? ENV["STEP"].to_i : 1
    ActiveRecord::MigrationContext.new("db/migrate/", ActiveRecord::Base.connection.schema_migration).rollback(step)
  end

  task :environment do
    # ActiveRecord::Base.establish_connection(db_config['development'])
  end
end
