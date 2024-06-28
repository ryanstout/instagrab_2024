# Create a hotmail account
require_relative "./utils"
require_relative "./browser"
require_relative "./proxies"
require_relative "./database"
require "faker"

class InstagramPullFollowers
  def initialize(username, password, profile_to_pull, proxy)
    @wait_time = 3 * 60

    @browser = new_browser(proxy)
    @page = @browser.create_page
  end
end

if __FILE__ == $0
  username = `op item get "instagram.com-lostupgrades" --vault "Ryans" --field username`
  password = `op item get "instagram.com-lostupgrades" --vault "Ryans" --field password`
  profile_to_pull = "lostupgrades"
  proxy = Proxies.get_random

  InstagramPullFollowers.new(username, password, profile_to_pull, proxy)
end
