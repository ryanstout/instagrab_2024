require_relative "./env"
require_relative "./browser"
require_relative "./outlook"
require_relative "./instagram_signup"
require "faker"

def check_pixelscan(browser)
  # Check if the browser is working
  page = browser.create_page
  puts "Load pixelscan and hit enter if it looks good"

  gets
end

def ig_signup(browser, user, proxy)
  # Now leave the tab open and do the IG signup
  InstagramSignup.new(browser, user.email, user.full_name, user.email_prefix, user.password)
end

if __FILE__ == $0
  puts "Usage: ruby create_user.rb"

  # When resuming after a failure
  # user = User.first
  # proxy = user.proxy_pool
  # browser = new_browser(proxy)
  # InstagramSignup.new(browser, user.email, user.full_name, user.email_prefix, user.password)

  # exit()

  # Create credentials
  full_name = Faker::Name.name
  email_prefix = (full_name.downcase.gsub(/[^a-z0-9. ]/, "").gsub(/\s+/, ".") + rand(100).to_s).gsub("..", ".").gsub("..", ".").gsub("..", ".").gsub("..", ".")
  full_email = email_prefix + "@outlook.com"
  password = Faker::Internet.password(min_length: 16, max_length: 25)

  # full_name = "Lourie D'Amore"
  # email_prefix = "lourie.damore17"
  # full_email = "lourie.damore17@outlook.com"
  # password = "rKXosrL6Nz8CCvMFTHaJZAhb"

  puts({
    full_name: full_name,
    email_prefix: email_prefix,
    full_email: full_email,
    password: password,
  }.inspect)

  # Create a browser with a registered proxy
  proxy = ProxyPool.get_random
  puts "Using proxy: #{proxy.inspect}"
  @browser = new_browser(proxy)

  begin
    check_pixelscan(@browser)

    user = User.add_user(email_prefix, full_email, full_name, password, proxy.id)

    # Do the outlook registration
    Outlook.new(@browser, full_name, email_prefix, password)

    user.signed_up!

    # Set the proxy as assigned
    proxy.update(state: 2)

    # Now leave the tab open and do the IG signup

    puts "Create Instagram User: #{email_prefix}\n#{email}\n#{password}"
    gets

    user.update(state: 3)

    # InstagramSignup.new(browser, user.email, user.full_name, user.email_prefix, user.password)
  rescue Exception => e
    puts "\n\n--- Be sure to rest the proxy with id #{proxy.id} ---\n\n"
    raise e
  end
end
