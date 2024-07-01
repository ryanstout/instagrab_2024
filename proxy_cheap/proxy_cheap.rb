# https://app.swaggerhub.com/apis-docs/Proxy-Cheap/API/1.5.3

require "httparty"
require "json"

class ProxyCheapAPI
  include HTTParty
  base_uri "https://api.proxy-cheap.com"

  def initialize(api_key, api_secret)
    @headers = {
      "X-Api-Key" => api_key,
      "X-Api-Secret" => api_secret,
      "Content-Type" => "application/json",
    }
  end

  # def register_mobile_proxy(location, plan)
  #   options = {
  #     headers: @headers,
  #     body: { type: "mobile", location: location, plan: plan }.to_json,
  #   }

  #   response = self.class.post("/proxies", options)
  #   if response.success?
  #     puts "Proxy registered successfully: #{response["data"]}"
  #   else
  #     raise "Proxy registration failed: #{response["error"]}"
  #   end
  # end

  def fetch_proxies
    options = {
      headers: @headers,
    }

    response = self.class.get("/proxies", options)
    if response.success?
      puts "RESPONSE: #{response.inspect}"
      return response["proxies"]
    else
      raise "Failed to fetch proxies: #{response["error"]}"
    end
  end

  def order_configuration
    data = {
      networkType: "MOBILE",
      ipVersion: "IPv4",
      country: "US",
      region: "CO",
    # # isp: "string",
    # proxyProtocol: "HTTP",
    # authenticationType: "IP_WHITELIST",
    # ipWhitelist: [
    #   "216.14.174.91",
    # ],
    # # package: "string",
    # quantity: 1,
    # couponCode: "",
    # bandwidth: 0,
    # isAutoExtendEnabled: true,
    # autoExtendBandwidth: 0,
    }

    options = {
      headers: @headers,
      body: data.to_json,
    }

    response = self.class.post("/order/configuration", options)

    binding.irb
    if response.success?
      puts "Proxy configuration ordered successfully: #{response["data"]}"
    else
      raise "Proxy configuration order failed: #{response["error"]}"
    end
  end

  def order_mobile_options(quantity)
    data = {
      networkType: "MOBILE",
      ipVersion: "IPv4",
      country: "US",
      region: "CO",
      # isp: "string",
      proxyProtocol: "SOCKS5",
      authenticationType: "IP_WHITELIST",
      ipWhitelist: [
        "216.14.174.91",
      # "38.143.242.52"
      ],
      # package: "string",
      quantity: quantity,
      # couponCode: "string",
      bandwidth: 0,
    # isAutoExtendEnabled: true,
    # autoExtendBandwidth: 0,
    }
    return data
  end

  def order_mobile_price
    options = {
      headers: @headers,
      body: order_mobile_options.to_json,
    }

    response = self.class.post("/order/price", options)

    if response.success?
      return response["finalPrice"]
    else
      raise "Failed to get price: #{response["error"]}"
    end
  end

  def fetch_proxy_by_id(id)
    options = {
      headers: @headers,
    }

    response = self.class.get("/proxies/#{id}", options)
    binding.irb
    if response.success?
      return response["proxy"]
    else
      raise "Failed to fetch proxy: #{response["error"]}"
    end
  end

  def fetch_proxies_from_order_by_id(id)
    options = {
      headers: @headers,
    }

    response = self.class.get("/orders/#{id}/proxies", options)
    if response.success?
      return response
    else
      raise "Failed to fetch order: #{response["error"]}"
    end
  end

  def order_mobile(quantity)
    final_price = order_mobile_price

    if final_price != 50
      raise "Final price is not 50: #{final_price}"
    end

    options = {
      headers: @headers,
      body: order_mobile_options(quantity).to_json,
    }

    response = self.class.post("/order/execute", options)
    binding.irb

    # response looks like:
    # {"id"=>"c446c509-3581-11ef-a278-0ac79cee8129", "periodInMonths"=>"1", "totalPrice"=>"50"}
    # (id is the order id)

    if response["message"] && response["message"] == "INSUFFICIENT_BALANCE"
      raise "Insufficient balance"
    end

    if response.success?
      return response
    else
      raise "Failed to complete order: #{response["error"]}"
    end
  end
end

if __FILE__ == $0
  quantity = ARGV[0].to_i

  proxy_cheap = ProxyCheapAPI.new("498ceb96-c11a-42aa-8a2c-718a973651da", "83317f46-1cf4-4d5b-bf90-bf7668c34a0f")

  # result = proxy_cheap.fetch_proxies
  # binding.irb
  # exit
  response = proxy_cheap.order_mobile(quantity)

  order_id = response["id"]

  loop do
    results = proxy_cheap.fetch_proxies_from_order_by_id(order_id)

    if results && results.all? { |r| r["status"] == "ACTIVE" }
      # Proxy is activated

      # Add the result to the database
      results.each do |result|
        proxy_url = "socks5://#{result["connection"]["connectIp"]}:#{result["connection"]["sock5Port"]}"
        ProxyPool.add_proxy(proxy_url, "America/Denver")
      end

      break
    end

    puts "Waiting for proxy, currently: #{results.map { |r| r["status"] }.inspect}"
    sleep 60
  end

  puts "Added #{quantity} proxies to the database"
end
