# Request specs default to www.example.com, which the app redirects to the bare
# domain. Use the bare domain unless a spec opts into www explicitly.
RSpec.configure do |config|
  config.before(type: :request) { host! "example.com" }
end
