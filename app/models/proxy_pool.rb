require_relative "./base"

class ProxyPool < ActiveRecord::Base
  def self.add_proxy(proxy, timezone_str)
    self.create(proxy: proxy, timezone_str: timezone_str, state: 0)
  end

  def self.get_random
    # "socks5://51.91.197.157:3072"

    # Grab a random proxy, mark it as state=1
    proxy = self.find_by(state: 0).order("RANDOM()").limit(1)

    proxy = proxy[0]

    # Mark the proxy as being assigned
    proxy.update(state: 1)

    return proxy
  end

  def self.get_temp_random
    proxy = self.find_by(state: 1).order("RANDOM()").limit(1)

    proxy = proxy[0]
    return proxy
  end
end
