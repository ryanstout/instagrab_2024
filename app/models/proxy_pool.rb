require_relative "./base"

class ProxyPool < ActiveRecord::Base
  def self.add_proxy(proxy, timezone_str)
    self.create(proxy: proxy, timezone_str: timezone_str, state: 0)
  end

  def self.get_random(dev = false)
    # "socks5://51.91.197.157:3072"

    # Grab a random proxy, mark it as state=1
    proxy = self.where(state: 0, dev: dev).order("RANDOM()").limit(1).first

    raise "No proxy found" if proxy.nil?

    # Mark the proxy as being assigned
    proxy.update(state: 1)

    return proxy
  end

  def self.get_temp_random(dev = true)
    proxy = self.where(state: 0, dev: dev).order("RANDOM()").limit(1).first

    raise "No proxy found" if proxy.nil?

    return proxy
  end
end
