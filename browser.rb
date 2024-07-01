require "ferrum"
require "uri"

def parse_proxy_url(proxy_url)
  puts "Parse: #{proxy_url}"
  uri = URI.parse(proxy_url)

  protocol = uri.scheme
  host = uri.host
  port = uri.port
  user, pass = uri.userinfo.split(":") if uri.userinfo

  return { protocol: protocol, host: host, port: port, user: user, password: pass }.compact.reject { |k, v| v.to_s.empty? }
end

def new_browser(proxy = nil)
  script = <<~JS
    if (key === 'document')
        return iframe.contentDocument || iframe.contentWindow.document;

        // iframe.contentWindow.frameElement === iframe // must be true
        if (key === 'frameElement') {
          return iframe
        }
        return Reflect.get(target, key)
      }
    }
  JS

  if proxy
    # Split parts of the proxy
    proxy_url = proxy["proxy"]
    proxy_parts = parse_proxy_url(proxy_url)
    proxy_parts.delete("protocol")

    puts "Running with proxy: #{proxy_parts.inspect}"
    proxy_options = {
      proxy: proxy_parts,
    }
  else
    proxy_options = {}
  end

  browser = Ferrum::Browser.new(
    # proxy: { host: "51.91.197.157", port: "3054", user: nil, pass: nil },
    timeout: 10 * 60,
    headless: false,
    browser_options: {
      "disable-blink-features": "AutomationControlled",
      "webrtc-ip-handling-policy": "disable_non_proxied_udp",
      "force-webrtc-ip-handling-policy": nil,
    # "timezone": "America/Denver",
    },
    # window_size: [3296, 3054],
    window_size: [1296, 2054],
    # args: [' --proxy-server=#{proxy}'],
    **proxy_options,
  )
  browser.evaluate_on_new_document(script)
  browser.instance_variable_set(:@__proxy, proxy)

  # Wrap the create_page method to set the proxy
  def browser.create_page
    page = super
    proxy = @__proxy

    if @__proxy
      puts "Setting timezone to: #{proxy["timezone_str"]}"
      page.command("Emulation.setTimezoneOverride", timezoneId: proxy["timezone_str"])
    end
    page
  end

  return browser
end
