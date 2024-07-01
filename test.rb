# Open a browser for testing

require_relative "./browser"
require_relative "./proxies"

proxy = Proxies.get_temp_random
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
