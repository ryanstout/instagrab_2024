require "ferrum"
require "uri"
require "digest"
require "fileutils"

def parse_proxy_url(proxy_url)
  puts "Parse: #{proxy_url}"
  uri = URI.parse(proxy_url)

  protocol = uri.scheme
  host = uri.host
  port = uri.port
  user, pass = uri.userinfo.split(":") if uri.userinfo

  # return { protocol: protocol, host: host, port: port, user: user, password: pass }.compact.reject { |k, v| v.to_s.empty? }
  return { host: host, port: port, user: user, password: pass }.compact.reject { |k, v| v.to_s.empty? }
  # return { 'proxy-server': proxy_url }
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

  other_options = {}
  bos = {}

  if proxy
    # Split parts of the proxy
    proxy_url = proxy.proxy
    proxy_parts = parse_proxy_url(proxy_url)
    # proxy_parts.delete("protocol")
    # proxy_parts["user"] = nil
    # proxy_parts["pass"] = nil

    puts "Running with proxy: #{proxy_parts.inspect}"

    # $proxy = Ferrum::Proxy.start(host: "127.0.0.1", port: 27493)
    # # $proxy.rotate(**proxy_parts)
    # $proxy.instance_variable_get(:@server).config[:ProxyURI] = URI.parse(proxy_uri)
    # # puts "Running with proxy: #{proxy_url}"
    # other_options[:proxy] = { host: $proxy.host, port: $proxy.port }

    other_options[:proxy] = proxy_parts
    # bos = {
    #   "proxy-server": proxy_url,
    # }
  end

  if false
    # run with user_data
    bos["no-sandbox"] = nil
    bos["incognito"] = nil

    user_data_dir = "temp/#{Digest::MD5.hexdigest(proxy_url.to_s)}"
    user_data_dir = File.expand_path(user_data_dir)
    puts "User Data Dir: #{user_data_dir}"
    other_options["user_data_dir"] = user_data_dir
    FileUtils.mkdir_p(user_data_dir)
  end

  browser = Ferrum::Browser.new(
    # proxy: { host: "51.91.197.157", port: "3054", user: nil, pass: nil },
    timeout: 10 * 60,
    headless: false,
    browser_options: {
      "disable-blink-features": "AutomationControlled",
      "webrtc-ip-handling-policy": "disable_non_proxied_udp",
      "force-webrtc-ip-handling-policy": nil,
      **bos,
    # "timezone": "America/Denver",
    },
    # window_size: [3296, 3054],
    window_size: [1296, 2054],
    proxy: proxy_parts,
    # args: [' --proxy-server=#{proxy}'],
    **other_options,
  )
  browser.evaluate_on_new_document(script)
  browser.instance_variable_set(:@__proxy, proxy)

  # Wrap the create_page method to set the proxy
  def browser.create_page
    page = super
    proxy = @__proxy

    if @__proxy
      puts "Setting timezone to: #{proxy["timezone_str"]}"
      page.command("Emulation.setTimezoneOverride", timezoneId: proxy.timezone_str)
    end
    page
  end

  return browser
end
