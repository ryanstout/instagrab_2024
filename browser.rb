require "ferrum"

def new_browser(proxy_url = nil)
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

  if proxy_url
    # Split at the last :
    host = proxy_url.split(":")[0..-2].join(":")
    port = proxy_url.split(":")[-1]
    proxy_options = {
      proxy: {
        host: host,
        port: port,
      },
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
  # browser.command("Emulation.setTimezoneOverride", timezoneId: "America/Denver")
  browser.evaluate_on_new_document(script)

  return browser
end
