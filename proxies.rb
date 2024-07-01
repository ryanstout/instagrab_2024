require_relative "./database"

class Proxies
  @db = Database.new

  def self.get_random
    # "socks5://51.91.197.157:3072"

    # Grab a random proxy, mark it as state=1
    proxy = @db.db.execute("SELECT * FROM proxy_pool WHERE state = 0 ORDER BY RANDOM() LIMIT 1")

    proxy = proxy[0]

    # Mark the proxy as being assigned
    @db.db.execute("UPDATE proxy_pool SET state = 1 WHERE id = ?", [proxy["id"]])

    return proxy
  end

  def self.get_temp_random
    proxy = @db.db.execute("SELECT * FROM proxy_pool WHERE state = 1 ORDER BY RANDOM() LIMIT 1")

    proxy = proxy[0]
    return proxy
  end

  def self.db
    @db
  end
end

if __FILE__ == $0
  if ARGV.length == 0
    puts "Usage: ruby proxies.rb <proxy> <timezone_str>"
  else
    # Add ARGV[0] to the proxies
    Proxies.db.add_proxy(ARGV[0], ARGV[1])
  end
end
