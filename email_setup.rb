require "digest"
require "ferrum"
require_relative "./onetime_pass"
require_relative "./utils"
require_relative "./browser"
require_relative "./app/models/proxy_pool"

proxy_server = ProxyPool.get_random

# Just start a browser and leave it open
@browser = new_browser(proxy_server)
@page = @browser.create_page

sleep 1000000000
