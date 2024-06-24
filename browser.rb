def new_browser
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

  browser = Ferrum::Browser.new(
    # proxy: { host: "51.91.197.157", port: "3054", user: nil, pass: nil },
    timeout: 10 * 60,
    headless: false,
    browser_options: {
      "disable-blink-features": "AutomationControlled",
      "webrtc-ip-handling-policy": "disable_non_proxied_udp",
      "force-webrtc-ip-handling-policy": nil,
    },
    # args: [
    #   # "--disable-blink-features=AutomationControlled",
    #   "--webrtc-ip-handling-policy=disable_non_proxied_udp",
    #   "--force-webrtc-ip-handling-policy",

    # ],
    # args: [' --proxy-server=#{proxy}'],
  )
  browser.evaluate_on_new_document(script)

  return browser
end
