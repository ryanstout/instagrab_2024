require_relative "./app/models/proxy_pool"

if __FILE__ == $0
  if ARGV.length == 0
    puts "Usage: ruby proxies.rb <proxy> <timezone_str>"
  else
    # Add ARGV[0] to the proxies
    ProxyPool.add_proxy(ARGV[0], ARGV[1])
  end
end
