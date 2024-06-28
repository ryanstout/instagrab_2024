require_relative "./database"
db = Database.new

class Proxies
  def self.get_random
    # "socks5://51.91.197.157:3072"

    # Grab a random proxy, mark it as state=1
    proxy = db.db.execute("SELECT idproxy FROM proxy_pool WHERE state = 0 ORDER BY RANDOM() LIMIT 1")

    proxy = proxy[0]

    # Mark the proxy as being assigned
    db.db.execute("UPDATE proxy_pool SET state = 1 WHERE idproxy = ?", [proxy["id"]])

    return proxy
  end
end

if __FILE__ == $0
  # Add ARGV[0] to the proxies
  db.add_proxy(ARGV[0])
end
