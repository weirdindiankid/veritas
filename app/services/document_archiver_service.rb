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

require 'digest'

class DocumentArchiverService
  def initialize(company)
    @company = company
    @errors = []
  end

  def archive_all
    results = []
    
    # Archive Terms of Service
    if @company.terms_url.present?
      result = archive_document(@company.terms_url, 'terms')
      results << result
    end
    
    # Archive Privacy Policy  
    if @company.privacy_url.present?
      result = archive_document(@company.privacy_url, 'privacy')
      results << result
    end
    
    {
      success: results.any? { |r| r[:success] },
      results: results,
      errors: @errors
    }
  end
  
  private
  
  def archive_document(url, document_type)
    begin
      # Scrape the document
      scrape_result = ScraperService.scrape_url(url)
      
      unless scrape_result[:success]
        error_msg = "Failed to scrape #{document_type}: #{scrape_result[:error]}"
        @errors << error_msg
        return { success: false, error: error_msg, document_type: document_type }
      end
      
      # Store in IPFS
      ipfs_result = IpfsService.store_document(
        scrape_result[:text],
        "#{@company.domain}_#{document_type.downcase.gsub(' ', '_')}_#{Time.current.to_i}.txt"
      )
      
      unless ipfs_result[:success]
        error_msg = "Failed to store #{document_type} in IPFS: #{ipfs_result[:error]}"
        @errors << error_msg
        return { success: false, error: error_msg, document_type: document_type }
      end
      
      # Create document record - use scraped title if available, otherwise generate one
      title = scrape_result[:title] || case document_type
                                         when 'terms'
                                           "#{@company.name} Terms of Service"
                                         when 'privacy'
                                           "#{@company.name} Privacy Policy"
                                         else
                                           "#{@company.name} Document"
                                         end

      # Always create new document for each archiving
      document = @company.documents.build(
        url: url,
        title: title,
        content: scrape_result[:text],
        ipfs_hash: ipfs_result[:hash],
        document_type: document_type,
        archived_at: Time.current
      )
      
      unless document.save
        error_msg = "Failed to save #{document_type}: #{document.errors.full_messages.join(', ')}"
        @errors << error_msg
        return { success: false, error: error_msg, document_type: document_type }
      end
      
      # Create archive for tracking changes (especially for re-archiving scenarios)
      previous_document = @company.documents.where(url: url).where.not(id: document.id).order(:archived_at).last
      
      if previous_document
        # Create archive for the new document to show the change
        archive = document.archives.build(
          checksum: Digest::SHA256.hexdigest(scrape_result[:text]),
          diff_content: "content changed",
          archived_by: "system",
          ipfs_hash: ipfs_result[:hash]
        )
        
        # Set previous_archive if the previous document has archives
        if previous_document.archives.any?
          archive.previous_archive = previous_document.archives.order(:version).last
        end
        
        archive.save!
      end
      
      # Pin to IPFS for persistence
      IpfsService.pin_document(ipfs_result[:hash])
      
      {
        success: true,
        document: document,
        document_type: document_type,
        ipfs_hash: ipfs_result[:hash],
        scraped_content_length: scrape_result[:text]&.length || 0
      }
      
    rescue => e
      error_msg = "Unexpected error archiving #{document_type}: #{e.message}"
      Rails.logger.error error_msg
      Rails.logger.error e.backtrace.join("\n")
      @errors << error_msg
      { success: false, error: error_msg, document_type: document_type }
    end
  end
end