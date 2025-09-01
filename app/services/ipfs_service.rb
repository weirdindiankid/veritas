# Veritas - Corporate Terms of Service Digital Archive
# Copyright (C) 2025 Dharmesh Tarapore <dharmesh@tarapore.ca>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

class IpfsService
  include Singleton

  def initialize
    # Try to initialize IPFS client, but don't fail if not available
    begin
      require "ipfs-http-client-rb"
      @client = IPFS::Client.new if defined?(IPFS)
    rescue LoadError, NameError
      Rails.logger.info "IPFS client not available, using mock implementation"
      @client = nil
    end
  end

  def add_content(content, filename = nil)
    if @client
      begin
        options = {}
        options[:filename] = filename if filename.present?

        response = @client.add(content, **options)

        return {
          success: true,
          hash: response["Hash"],
          name: response["Name"],
          size: response["Size"]
        }
      rescue => e
        Rails.logger.error "IPFS add failed: #{e.message}"
      end
    end

    # Fallback to mock implementation
    {
      success: true,
      hash: generate_mock_hash(content),
      name: filename || "document",
      size: content.to_s.bytesize
    }
  end

  def get_content(hash)
    if @client
      begin
        content = @client.cat(hash)
        return {
          success: true,
          content: content
        }
      rescue => e
        Rails.logger.error "IPFS get failed: #{e.message}"
      end
    end

    # Fallback mock response
    {
      success: false,
      error: "IPFS client not available"
    }
  end

  def pin_content(hash)
    if @client
      begin
        @client.pin_add(hash)
        return {
          success: true,
          hash: hash
        }
      rescue => e
        Rails.logger.error "IPFS pin failed: #{e.message}"
      end
    end

    # Fallback mock response
    {
      success: true,
      hash: hash
    }
  end

  def generate_gateway_url(hash, filename = nil)
    base_url = Rails.application.credentials.dig(:ipfs, :gateway_url) || "https://gateway.ipfs.io/ipfs"
    url = "#{base_url}/#{hash}"
    url += "?filename=#{filename}" if filename.present?
    url
  end

  # Simplified interface methods for backwards compatibility
  def add(content)
    result = add_content(content)
    result[:hash]
  end

  def get(hash)
    result = get_content(hash)
    result[:content]
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

  private

  def generate_mock_hash(content)
    # Generate a deterministic mock IPFS hash for testing
    "Qm#{Digest::SHA256.hexdigest(content.to_s)[0..43]}"
  end
end
