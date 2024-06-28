# Create a hotmail account
require_relative "./utils"
require_relative "./browser"
require_relative "./proxies"
require_relative "./database"
require "faker"

class Hotmail
  def initialize(proxy, full_name, email_prefix, password)
    @wait_time = 3 * 60

    @browser = new_browser(proxy)
    @page = @browser.create_page

    puts "Load page1"
    @page.go_to("https://www.microsoft.com/en-us/microsoft-365/outlook/email-and-calendar-software-microsoft-outlook")
    puts "Waiting for page"
    sleep 45 + rand(5)

    # Stop the page loading
    @page.stop

    # Wait for span with text "Create free account"
    puts "Find button"
    create_button = wait_for_selector(@page, 'a[data-bi-ecn="Create free account"]', @wait_time)
    puts "Found"

    sleep 5 + rand(5)
    puts "Click create free account"
    # create_button.click

    # Get the href from the button
    href = create_button.attribute("href")
    puts "Load: #{href}"
    @page.go_to(href)
    puts "Select email"

    new_email_field = wait_for_selector(@page, "input[placeholder=\"New email\"]", @wait_time)

    # Generate a random email prefix using faker
    name_parts = full_name.split
    first_name = name_parts.first
    last_name = name_parts[1..].join(" ")

    realistic_type(@page, new_email_field, email_prefix)
    sleep rand(4)
    new_email_field.type(:Enter)

    sleep 5 + rand(5)

    puts "Password"
    create_password_filed = wait_for_selector(@page, "input[placeholder=\"Create password\"]", @wait_time)
    realistic_type(@page, create_password_filed, password)
    sleep rand(4)
    # create_password_filed.type(:Enter)

    sleep 2 + rand(4)
    # Uncheck the input[data-testid="iOptinEmail"] field
    puts "Click optinemail"
    wait_for_selector(@page, "input[id=\"iOptinEmail\"]", @wait_time).click
    puts "Clicked"

    sleep 2 + rand(4)
    # Click the next button
    puts "Find next"
    wait_for_xpath(@page, "//button[@value='Next' or text()='Next']", @wait_time).click
    puts "Clicked Next"

    sleep 5 + rand(5)

    puts "Find first name"

    # Fill out first and last names
    first_name_field = wait_for_selector(@page, "input[placeholder=\"First name\"]", @wait_time)
    realistic_type(@page, first_name_field, first_name)
    sleep 2 + rand(4)

    puts "Find last name"

    last_name_field = wait_for_selector(@page, "input[placeholder=\"Last name\"]", @wait_time)
    realistic_type(@page, last_name_field, last_name)
    sleep 2 + rand(4)

    # Click the next button
    wait_for_xpath(@page, "//button[text()='Next']", @wait_time).click

    sleep 6 + rand(6)

    # Set Birthday
    set_birthday

    # Sleep for human intervention
    puts "Beat the robots"
    gets
  end

  def set_birthday
    month_field = wait_for_selector(@page, "select[aria-label=\"Birth month\"]", @wait_time)

    # Select a random month
    month_num = rand(1..12)

    # Convert month_num to Month strings
    months = %w{January February March April May June July August September October November December}
    month_name = months[month_num - 1]

    # Use the arrow keys
    set_field_with_arrow(month_field, month_name)

    # Day
    day_field = wait_for_selector(@page, "select[aria-label=\"Birth day\"]", @wait_time)

    # Select a random day
    day_num = rand(1..28)

    # Use the arrow keys
    set_field_with_arrow(day_field, day_num.to_s)

    # Year
    year_field = wait_for_selector(@page, "input[placeholder=\"Year\"]", @wait_time)
    realistic_type(@page, year_field, rand(1950..2000).to_s)

    # Click the next button
    wait_for_xpath(@page, "//button[text()='Next']", @wait_time).click

    # Click button with text "Yes"
    sleep 15 + rand(6)
    wait_for_xpath(@page, "//button[text()='Yes']", @wait_time).click
  end
end

if __FILE__ == $0
  @db = Database.new

  full_name = Faker::Name.name
  email_prefix = (full_name.downcase.gsub(/[^a-z0-9. ]/, "").gsub(/\s+/, ".") + rand(100).to_s).gsub("..", ".").gsub("..", ".").gsub("..", ".").gsub("..", ".")
  password = Faker::Internet.password(min_length: 16, max_length: 25)

  proxy = Proxies.get_random

  @db.add_user(email_prefix, full_email, full_name, password, proxy)
  Hotmail.new(proxy, full_name, email_prefix, password)

  full_email = email_prefix + "@outlook.com"
  @db.signed_up(full_email, proxy)
end
