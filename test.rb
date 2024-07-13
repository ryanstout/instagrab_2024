# Open a browser for testing

require_relative "./env"
require_relative "./browser"

# proxy = ProxyPool.get_temp_random(true)
# proxy = ProxyPool.last
# proxy = ProxyPool.new(proxy: "socks5://51.91.197.157:3012", timezone_str: "America/Denver")

# brightdata

# proxy = ProxyPool.where(id: 2).first
# proxy = ProxyPool.new(proxy: "http://brd-customer-hl_64fb6b1c-zone-isp_proxy1:94iku6bcrzxo@brd.superproxy.io:22225", timezone_str: "America/New_York")
# proxy.proxy = ProxyPool.maybe_use_forwarding_proxy(proxy.proxy)
# proxy = ProxyPool.new(proxy: "http://127.0.0.1:22225", timezone_str: "America/New_York")
# proxy = ProxyPool.new(proxy: "http://zkC3:2QLk@deeprig:16310", timezone_str: "America/Denver")
proxy = ProxyPool.new(proxy: "socks5://instagrab:instagrab@192.168.1.231:10881", timezone_str: "America/Denver")
# proxy = ProxyPool.new(proxy: "socks5://192.168.1.231:42376", timezone_str: "America/Denver")

proxy.proxy = ProxyPool.maybe_use_forwarding_proxy(proxy.proxy)
puts "PROXY: #{proxy.inspect}"

browser = new_browser(proxy)
page = browser.create_page

sleep 10000000

page.go_to("https://witharsenal.com/")

sleep 2

js_code = <<~JS
  arguments[0]({foo: "bar"})
JS

# Execute the asynchronous JavaScript code and get the result
puts "RUN CODE: #{js_code}"
result = page.evaluate_async(js_code, 2000)

puts "Result: #{result.inspect}"

sleep 1000000
