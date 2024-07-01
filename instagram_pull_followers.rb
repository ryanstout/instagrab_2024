# Pull the followers list from a profile

# NOTE: Not done, just using in console JS for now

require_relative "./utils"
require_relative "./browser"
require_relative "./proxies"
require_relative "./instagrab"
require_relative "./app/models/profile"
require "faker"

class InstagramPullFollowers < Instagrab
  def initialize(username, password, one_time, profile_to_pull, proxy)
    @wait_time = 3 * 60

    @username = username
    @password = password
    @one_time = one_time

    @browser = new_browser(proxy)
    @page = @browser.create_page

    login

    # Load the profile
    @page.go_to("https://instagram.com/#{profile_to_pull}")
    sleep 15 + rand(5)

    # Click on the following button
    puts "Find following link"
    following_button = wait_for_selector(@page, "a[href=\"/#{profile_to_pull}/following/\"]", @wait_time)
    puts "Found, click"
    following_button.click

    sleep 10 + rand(5)
    puts "Look for following list"

    # Find the first div with the text of "Following"
    following_div = wait_for_xpath(@page, "//div[text()='Following']", @wait_time)
    following_div.click

    sleep 10 + rand(5)

    # Run the JS to get the list of followers
    script = File.read("instagram_pull_followers.js")

    binding.irb

    followers = @page.evaluate_async(script, 30 * 60)

    binding.irb

    followers.each do |profile_name|
      Profile.create(profile_name: profile_to_pull, pulled: false, depth: 1)
    end

    binding.irb
  end
end

if __FILE__ == $0
  # username = `op item get "instagram.com-lostupgrades" --vault "Ryans" --field username`
  # password = `op item get "instagram.com-lostupgrades" --vault "Ryans" --field password`
  # one_time = `op item get "instagram.com-lostupgrades" --vault "Ryans" --field "one-time password"`

  # Get a random user who has registered for IG
  user = User.where(state: 3).order("RANDOM()").first

  profile_to_pull = "shainblumphotography"
  # profile_to_pull = "lostupgrades"
  # proxy = Proxies.get_random
  proxy = nil

  InstagramPullFollowers.new(user.email, user.password, one_time, profile_to_pull, proxy)
end
