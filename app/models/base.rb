require "active_record"

# Establish connection
ActiveRecord::Base.establish_connection(
  adapter: "postgresql",
  host: "deeprig",
  username: "instagrab",
  password: "v3KMs33EwJa7xVdXY6Vj",
  database: "instagrab",
)
