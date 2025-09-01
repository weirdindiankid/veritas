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