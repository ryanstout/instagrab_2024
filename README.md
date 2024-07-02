# Instagrab 2024

Pull instagram for fun


# 1. Add proxies to the pool manually

`bundle exec ruby proxies.rb {socks5://host:port} {timezone_str}`

# 1.b Or add them automatically
(takes a while, setup to order mobile proxies)

`bundle exec ruby proxy_cheap/proxy_cheap.rb {quantity}`

# 2. Create a user (outlook.com email) and IG

`bundle exec ruby create_user.rb`





# TODOS:
- finish pulling from a profile
- maybe figure out how to set up MFA for more reliability.
- make instagrab.rb pull a profile from the db, then start pulling it. Update it to save in folders.
- run the pulling in multiple threads/browsers?


# Hotmail
winfred.damore.cpa57@outlook.com / BJT5E2u2tE1tBl4CPhN
ig: winfreddamore

{"full_name":"Mrs. Shawnta Windler","email":"mrs.shawnta.windler91","password":"KKA9thHwTskdHD0b25"}


# IG
darwin_marksdarwin_marks / a2oEpTV1rY6AD9vSTlWnFAFS




# BrightData API token
e9aaf622-e49f-4fe4-98c8-1eb73525b6d1




proxy-login-automator -local_host '127.0.0.1' -local_port 22225 -remote_host 'brd.superproxy.io' -remote_port 22225 -usr 'brd-customer-hl_64fb6b1c-zone-isp_proxy1' -pwd '94iku6bcrzxo'

tinyproxy -d -p 22225 -u 'brd-customer-hl_64fb6b1c-zone-isp_proxy1:94iku6bcrzxo' -r brd.superproxy.io:22225


node proxy.js --local 22225 --remote "http://brd-customer-hl_64fb6b1c-zone-isp_proxy1:94iku6bcrzxo@brd.superproxy.io:22225"