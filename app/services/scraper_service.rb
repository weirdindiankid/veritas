require 'httparty'
require 'nokogiri'
require 'digest'

class ScraperService
  include HTTParty
  
  USER_AGENTS = [
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
    'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
  ].freeze
  
  def initialize(url)
    @url = url
    @headers = {
      'User-Agent' => USER_AGENTS.sample,
      'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
      'Accept-Language' => 'en-US,en;q=0.5',
      'Accept-Encoding' => 'gzip, deflate',
      'Connection' => 'keep-alive'
    }
  end
  
  def scrape
    begin
      response = HTTParty.get(@url, {
        headers: @headers,
        timeout: 30,
        follow_redirects: true
      })
      
      if response.success?
        content = extract_content(response.body)
        checksum = generate_checksum(content[:text])
        
        {
          success: true,
          title: content[:title],
          text: content[:text],
          html: response.body,
          checksum: checksum,
          scraped_at: Time.current,
          url: @url,
          status_code: response.code
        }
      else
        {
          success: false,
          error: "HTTP #{response.code}: #{response.message}",
          status_code: response.code
        }
      end
    rescue Net::OpenTimeout, Net::ReadTimeout => e
      Rails.logger.error "Scraping timeout for #{@url}: #{e.message}"
      { success: false, error: 'Request timeout' }
    rescue => e
      Rails.logger.error "Scraping failed for #{@url}: #{e.message}"
      { success: false, error: e.message }
    end
  end
  
  def self.scrape_url(url)
    new(url).scrape
  end
  
  def self.scrape_company_documents(company)
    results = []
    
    # Scrape terms of service
    if company.terms_url.present?
      result = scrape_url(company.terms_url)
      result[:document_type] = 'terms'
      results << result
    end
    
    # Scrape privacy policy
    if company.privacy_url.present?
      result = scrape_url(company.privacy_url)
      result[:document_type] = 'privacy'
      results << result
    end
    
    results
  end
  
  private
  
  def extract_content(html)
    doc = Nokogiri::HTML(html)
    
    # Remove script and style elements
    doc.css('script, style, nav, footer, header, aside').remove
    
    # Try to find the main content area
    main_content = doc.css('main, article, .content, #content, .main, #main').first
    content_element = main_content || doc.css('body').first
    
    # Extract title
    title = doc.css('title').first&.text&.strip || 
            doc.css('h1').first&.text&.strip || 
            'Untitled Document'
    
    # Clean up title
    title = title.gsub(/\s+/, ' ').strip
    
    # Extract and clean text content
    text_content = content_element&.text || ''
    
    # Remove excessive whitespace and normalize
    clean_text = text_content
      .gsub(/\s+/, ' ')          # Replace all whitespace sequences with single space
      .strip
    
    {
      title: title,
      text: clean_text
    }
  end
  
  def generate_checksum(content)
    Digest::SHA256.hexdigest(content.to_s.strip)
  end
end