require 'ipfs'

class IpfsService
  include Singleton
  
  def initialize
    @client = IPFS::Client.new
  end
  
  def add_content(content, filename = nil)
    begin
      options = {}
      options[:filename] = filename if filename.present?
      
      response = @client.add(content, **options)
      
      {
        success: true,
        hash: response['Hash'],
        name: response['Name'],
        size: response['Size']
      }
    rescue => e
      Rails.logger.error "IPFS add failed: #{e.message}"
      {
        success: false,
        error: e.message
      }
    end
  end
  
  def get_content(hash)
    begin
      content = @client.cat(hash)
      {
        success: true,
        content: content
      }
    rescue => e
      Rails.logger.error "IPFS get failed: #{e.message}"
      {
        success: false,
        error: e.message
      }
    end
  end
  
  def pin_content(hash)
    begin
      @client.pin_add(hash)
      {
        success: true,
        hash: hash
      }
    rescue => e
      Rails.logger.error "IPFS pin failed: #{e.message}"
      {
        success: false,
        error: e.message
      }
    end
  end
  
  def generate_gateway_url(hash, filename = nil)
    base_url = Rails.application.credentials.dig(:ipfs, :gateway_url) || "https://gateway.ipfs.io/ipfs"
    url = "#{base_url}/#{hash}"
    url += "?filename=#{filename}" if filename.present?
    url
  end
  
  def self.store_document(document_content, filename = nil)
    instance.add_content(document_content, filename)
  end
  
  def self.retrieve_document(hash)
    instance.get_content(hash)
  end
  
  def self.pin_document(hash)
    instance.pin_content(hash)
  end
end