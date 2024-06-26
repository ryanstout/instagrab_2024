# Create a hotmail account
require_relative "./utils"
require_relative "./browser"
require "faker"

class InstagramSignup
  def initialize(email, name, username, password)
    @wait_time = 3 * 60

    @browser = new_browser()
    @page = @browser.create_page

    @page.go_to("https://instagram.com")

    # Click span with the text "Log in"
    wait_for_xpath(@page, "//span[text()='Log in']", @wait_time).click

    sleep 4 + rand

    # Click span with "Sign up"
    wait_for_xpath(@page, "//span[text()='Sign up']", @wait_time).click
    sleep 14 + rand

    # Enter email to input[aria-label="Mobile Number or Email"]
    email_field = wait_for_selector(@page, 'input[aria-label="Mobile Number or Email"]', @wait_time)
    realistic_type(@page, email_field, email)
    sleep 1 + rand(3)

    # Enter full name
    full_name_field = wait_for_selector(@page, 'input[aria-label="Full Name"]', @wait_time)
    realistic_type(@page, full_name_field, name)
    sleep 1 + rand(3)

    # Ente username to input[aria-label="Username"]
    username_field = wait_for_selector(@page, 'input[aria-label="Username"]', @wait_time)
    realistic_type(@page, username_field, username)
    sleep 1 + rand(3)

    # Enter password to input[aria-label="Password"]
    password_field = wait_for_selector(@page, 'input[aria-label="Password"]', @wait_time)
    realistic_type(@page, password_field, password)
    sleep 1 + rand(3)

    # Click button with text "Sign up"
    wait_for_xpath(@page, "//button[text()='Sign up']", @wait_time).click
    sleep 1 + rand(3)

    # Now on the birthday page

    month_field = wait_for_selector(@page, "select[title=\"Month:\"]", @wait_time)

    day_field = wait_for_selector(@page, "select[title=\"Day:\"]", @wait_time)

    year_field = wait_for_selector(@page, "select[title=\"Year:\"]", @wait_time)

    # Click on button with text "Next"
    wait_for_xpath(@page, "//button[text()='Next']", @wait_time).click

    # Big sleep
    sleep 60 + rand(15)

    puts "Check the email"
    gets

    sleep 10
  end
end

if __FILE__ == $0
  # email =
  # name = Faker::Name.name
  # username = Faker::Internet.username
  # password = Faker::Internet.password

  # InstagramSignup.new(email, name, username, password)
end
