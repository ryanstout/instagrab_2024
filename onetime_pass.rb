require "rotp"
require "uri"

def fetch_otp(otpauth_url)
  begin
    # Parse the URL to extract the secret
    uri = URI.parse(otpauth_url)
    if uri.query.nil?
      raise "Invalid otpauth URL: query component is missing"
    end

    params = URI.decode_www_form(uri.query).to_h
    secret = params["secret"]

    if secret.nil?
      raise "Secret parameter is missing in the otpauth URL"
    end

    # Generate the OTP
    totp = ROTP::TOTP.new(secret)
    otp = totp.now

    return otp
  rescue => e
    puts "Error: #{e.message}"
    return nil
  end
end
