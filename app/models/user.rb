require_relative "./base"

class User < ActiveRecord::Base
  # Assuming the existence of a ProxyPool model that corresponds to the proxy_pool table
  belongs_to :proxy_pool, foreign_key: "proxy_id"

  # Class method to add a user
  def self.add_user(email_prefix, email, full_name, password, proxy_id)
    create(email_prefix: email_prefix, email: email, full_name: full_name, password: password, state: 1, proxy_id: proxy_id)
  end

  # Instance method to mark user as signed up
  def signed_up!
    update(state: 2)
    proxy_pool.update(state: 2) if proxy_pool
  end

  # Method to grab a user who hasn't done the Instagram registration
  # Sets state to 2 to indicate registration process has started
  def self.get_ig_unregistered_user
    User.transaction do
      user = User.where(state: 1).order(:id).lock(true).first
      if user
        user.update(state: 2)
        user
      else
        puts "No inactive users found to update."
        nil
      end
    end
  rescue ActiveRecord::LockWaitTimeout => e
    puts "Database is locked, transaction couldn't be completed: #{e.message}"
    raise e
  rescue ActiveRecord::StatementInvalid => e
    puts "An SQL error occurred: #{e.message}"
    raise e
  rescue => e
    puts "An unexpected error occurred: #{e.message}"
    raise e
  end
end
