require "digest"
require "ferrum"
require_relative "./onetime_pass"
require_relative "./utils"
require_relative "./browser"

proxy = "socks5://51.91.197.157:3072"

modal_image = <<-JS
  (function() {
    var div = document.querySelectorAll('article[role="presentation"]');

    var mainDiv = div[0].querySelector('div')[0]


  })()
JS

class Instagrab
  def url_hash(url)
    Digest::SHA256.hexdigest(url)
  end

  def cache_image(url, body)
    url_hash = self.url_hash(url)
    cache_path = File.join("cache", "#{url_hash}.jpg")
    # Write the image body to the file
    File.binwrite(cache_path, body)
  end

  def fetch_cached_image(url)
    url_hash = self.url_hash(url)

    cache_path = File.join("cache", "#{url_hash}.jpg")
    if File.exists?(cache_path)
      return File.binread(cache_path)
    else
      return nil
    end
  end

  def initialize
    @username = `op item get "instagram.com-lostupgrades" --vault "Ryans" --field username`
    @password = `op item get "instagram.com-lostupgrades" --vault "Ryans" --field password`
    @one_time = `op item get "instagram.com-lostupgrades" --vault "Ryans" --field "one-time password"`

    @wait_time = 2 * 60

    @browser = new_browser()
    @page = @browser.create_page

    # @page.network.intercept #(request_stage: :Response)
    @page.network.subscribe
    # @page.on(:request) do |request|
    #   puts "REQUEST: #{request.url}"
    #   request.continue
    # end
    # @page.on("Network.responseReceived") do |response|
    #   binding.irb
    #   puts "RESPONSE: #{response.url}"
    #   if response.url.match?(jpg_regex)
    #     response.body do |body|
    #       # Response should be a
    #       image = MiniMagick::Image.read(body)

    #       if image.width > 500 || image.height > 500
    #         cache_image(response.url, body)
    #       end
    #     end
    #   end
    # end

    login()

    # Regular expression to match .jpg URLs, including those with query parameters
    jpg_regex = /\.jpg(?:\?|$)/

    # @page.go_to("https://www.instagram.com/shainblumphotography/")
    @page.go_to("https://www.instagram.com/lostupgrades/")

    sleep 20 + rand(3)

    # Make sure
    wait_for_selector(@page, "a[href^='/p/']", @wait_time)

    sleep 5 + rand(3)

    # Get al elements that match a[href^="/p/"]
    links = @page.css("a[href^='/p/']")

    # Click the first link
    links.first.click

    # Have to click it twice for some reason
    # sleep 1.1 + rand
    # links.first.click

    sleep 2.6 + rand

    body = @page.at_css("body")

    last_image_url = "!!" # some non nil non url value

    images = []
    loop do
      sleep 2.4 + rand(2)
      image_url = largest_image_src(@page)

      if image_url == last_image_url
        puts "Last image url matches current image url, stopping. #{image_url.inspect}"
        break
      end

      if image_url.nil?
        puts "Image url is nil (maybe video), skipping."
      else
        image_body = find_image_in_traffic_history(@page, image_url)

        unless image_body
          puts "Image request size is 0, download in new tab: #{image_url.inspect}"

          image_body = download_image_url_in_new_tab(@browser, image_url)
        end

        if image_body
          # Save the image
          File.binwrite("images/image#{rand}.jpg", image_body)
        else
          puts "Failed to download image: #{image_url}"
        end

        last_image_url = image_url

        images << image_url if image_url
      end

      # See if there is the carousel arrow
      carousel_next_arrow = @page.at_css("article[role='presentation'] button[aria-label='Next']")
      if carousel_next_arrow
        carousel_next_arrow.click
      else
        body.type(:right)
      end
    end

    puts "Done with all"

    sleep 1000000
    print "After"

    @browser.quit
  end

  def login
    @page.go_to("https://instagram.com")

    wait_for_page_fully_loaded(@page)

    sleep 3.6 + rand

    username_field = wait_for_selector(@page, 'input[aria-label="Phone number, username, or email"]', @wait_time)
    realistic_type(@page, username_field, @username)

    sleep 0.4 + rand

    password_field = wait_for_selector(@page, 'input[aria-label="Password"]', @wait_time)
    realistic_type(@page, password_field, @password)

    sleep 0.2 + rand

    # Hit enter in the password field
    password_field.type(:Enter)

    sleep 2.3 + rand

    one_time = fetch_otp(@one_time)
    one_time_field = wait_for_selector(@page, 'input[aria-label="Security Code"]', @wait_time)
    realistic_type(@page, one_time_field, one_time)

    sleep 0.2 + rand
    one_time_field.type(:Enter)

    sleep 8 + rand

    # Get the div with //div[text()='Not now']
    not_now_div = wait_for_xpath(@page, "//div[text()='Not now']", @wait_time)
    not_now_div.click

    sleep 5 + rand

    # Click "Not now" button (something about notifications)
    not_now_button = wait_for_xpath(@page, "//button[text()='Not Now']", @wait_time)
    not_now_button.click
  end

  def search_for_photographer(page, handle)
    search_button = wait_for_selector(page, "span[aria-describedby=\":r15:\"]", @wait_time)
    search_button.click

    sleep 3.6 + rand

    search_input = wait_for_selector(page, "input[aria-label=\"Search input\"]", @wait_time)
    realistic_type(page, search_input, handle)

    sleep 2.3 + rand

    # Press enter
    search_input.type(:Enter)

    sleep 16 + rand

    # Find the link with the handle
    link = wait_for_selector(page, "a[href='/#{handle}/']", @wait_time)
    link.click
  end
end

Instagrab.new
