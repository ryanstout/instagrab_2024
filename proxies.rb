require_relative "./app/models/proxy_pool"

class Proxies
  def self.get_random
    # "socks5://51.91.197.157:3072"

    # Grab a random proxy, mark it as state=1
    proxy = ProxyPool.find_by(state: 0).order("RANDOM()").limit(1)

    proxy = proxy[0]

    # Mark the proxy as being assigned
    proxy.update(state: 1)

    return proxy
  end

  def self.get_temp_random
    proxy = ProxyPool.find_by(state: 1).order("RANDOM()").limit(1)

    proxy = proxy[0]
    return proxy
  end
end

if __FILE__ == $0
  if ARGV.length == 0
    puts "Usage: ruby proxies.rb <proxy> <timezone_str>"
  else
    # Add ARGV[0] to the proxies
    ProxyPool.add_proxy(ARGV[0], ARGV[1])
  end
end
