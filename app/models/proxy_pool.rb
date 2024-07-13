require_relative "./base"

class ProxyPool < ActiveRecord::Base
  @@child_pids = []

  def self.add_proxy(proxy, timezone_str)
    self.create(proxy: proxy, timezone_str: timezone_str, state: 0)
  end

  def self.handle_termination
    if @@child_pids.empty?
      Signal.trap("TERM") do
        begin
          @@child_pids.each do |pid|
            Process.kill("TERM", -pid) # Send the signal to the entire process group
          end
        rescue Errno::ESRCH
          puts "Process group #{pid} does not exist"
        end
        exit
      end
    end
  end

  def self.maybe_use_forwarding_proxy(proxy_url)
    if proxy_url.include?("superproxy") || proxy_url.include?("192.168.1.231")
      # We start a node process to relay
      rand_port = rand(10000..20000)
      puts "Starting relay on port: #{rand_port}"

      pid = Process.spawn("node proxy.js --local #{rand_port} --remote \"#{proxy_url}\"")

      @@child_pids << pid

      self.handle_termination

      new_proxy_url = "http://127.0.0.1:#{rand_port}"
      puts "Relay through: #{new_proxy_url}"
      return new_proxy_url
    else
      return proxy_url
    end
  end

  def self.get_random(dev = false)
    # "socks5://51.91.197.157:3072"

    # Grab a random proxy, mark it as state=1
    proxy = self.where(state: 0, dev: dev).order("RANDOM()").limit(1).first

    raise "No proxy found" if proxy.nil?

    # Mark the proxy as being assigned
    proxy.update(state: 1)

    # If the proxy is a forwarding proxy, we need to start a relay
    proxy.proxy = self.maybe_use_forwarding_proxy(proxy.proxy)

    return proxy
  end

  def self.get_temp_random(dev = true)
    proxy = self.where(state: 0, dev: dev).order("RANDOM()").limit(1).first

    raise "No proxy found" if proxy.nil?

    # If the proxy is a forwarding proxy, we need to start a relay
    proxy.proxy = self.maybe_use_forwarding_proxy(proxy.proxy)

    return proxy
  end
end
