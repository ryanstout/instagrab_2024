# Create a hotmail account
require_relative "./utils"
require_relative "./browser"
require_relative "./proxies"
require_relative "./app/models/user"
require "faker"

class InstagramSignup
  def initialize(email, name, username, password, proxy)
    @wait_time = 3 * 60

    @browser = new_browser(proxy)
    @page = @browser.create_page

    @page.go_to("https://instagram.com")
    puts "IG loaded"

    # Click span with the text "Log in"
    # wait_for_xpath(@page, "//span[text()='Log in']", @wait_time).click

    # sleep 4 + rand

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

    # Select a random month
    month_num = rand(1..12)

    # Convert month_num to Month strings
    months = %w{January February March April May June July August September October November December}
    month_name = months[month_num - 1]
    set_field_with_arrow(month_field, month_name)
    sleep 3 + rand(2)

    # Day
    day_field = wait_for_selector(@page, "select[title=\"Day:\"]", @wait_time)
    day_num = rand(1..28)
    set_field_with_arrow(day_field, day_num.to_s)
    sleep 3 + rand(2)

    # Year
    year_field = wait_for_selector(@page, "select[title=\"Year:\"]", @wait_time)

    year = rand(1950..2000).to_s
    set_field_with_arrow(year_field, year)
    sleep 3 + rand(2)

    # Click on button with text "Next"
    wait_for_xpath(@page, "//button[text()='Next']", @wait_time).click

    # Big sleep
    sleep 60 + rand(15)

    puts "Check the email"
    gets

    # Update the user to state=3
    user = User.where(email: email).first
    user.update(state: 3)
  end
end

if __FILE__ == $0
  # Grab the first user where signed_up = True and ig_registered = False
  user = User.get_ig_unregistered_user

  InstagramSignup.new(user["email"], user["name"], user["username"], user["password"], user["proxy_id"])
end
