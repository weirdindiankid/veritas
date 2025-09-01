Rails.application.configure do
  config.ipfs = ActiveSupport::OrderedOptions.new

  # IPFS node configuration
  config.ipfs.host = ENV.fetch("IPFS_HOST", "localhost")
  config.ipfs.port = ENV.fetch("IPFS_PORT", "5001").to_i
  config.ipfs.gateway_url = ENV.fetch("IPFS_GATEWAY_URL", "https://gateway.ipfs.io/ipfs")

  # Enable/disable IPFS features
  config.ipfs.enabled = ENV.fetch("IPFS_ENABLED", "true") == "true"
  config.ipfs.auto_pin = ENV.fetch("IPFS_AUTO_PIN", "true") == "true"
end
