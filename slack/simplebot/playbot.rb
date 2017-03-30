require 'http'
require 'json'

# rc = HTTP.post("https://slack.com/api/api.test")
# rc = HTTP.post("https://slack.com/api/auth.test", params: {
#   token: "xoxb-71305227729-G5Kx1u0HSRcMLc01XzoKtjA6"
# })


rc = HTTP.post("https://slack.com/api/chat.postMessage", params: {
  token: "xoxb-71305227729-G5Kx1u0HSRcMLc01XzoKtjA6",
  channel: "#general",
  text: "hello, from ian's slack demo",
  as_user: true
})
puts JSON.pretty_generate(JSON.parse(rc.body))
