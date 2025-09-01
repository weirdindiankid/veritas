require 'rails_helper'

RSpec.describe ScraperService, type: :service do
  describe '#initialize' do
    it 'sets the URL and headers' do
      service = ScraperService.new('https://example.com/terms')
      expect(service.instance_variable_get(:@url)).to eq('https://example.com/terms')
      expect(service.instance_variable_get(:@headers)).to include('User-Agent')
    end
  end

  describe '#scrape' do
    let(:url) { 'https://example.com/terms' }
    let(:service) { ScraperService.new(url) }

    context 'with successful response' do
      let(:html_content) do
        <<~HTML
          <!DOCTYPE html>
          <html>
          <head><title>Terms of Service</title></head>
          <body>
            <h1>Terms of Service</h1>
            <p>These are our terms of service.</p>
            <script>console.log('ignored');</script>
          </body>
          </html>
        HTML
      end

      before do
        stub_request(:get, url)
          .to_return(status: 200, body: html_content, headers: { 'Content-Type' => 'text/html' })
      end

      it 'returns successful result with extracted content' do
        result = service.scrape

        expect(result[:success]).to be true
        expect(result[:title]).to eq('Terms of Service')
        expect(result[:text]).to include('These are our terms of service')
        expect(result[:text]).not_to include('console.log') # Script removed
        expect(result[:html]).to eq(html_content)
        expect(result[:checksum]).to be_present
        expect(result[:scraped_at]).to be_within(1.second).of(Time.current)
        expect(result[:url]).to eq(url)
        expect(result[:status_code]).to eq(200)
      end

      it 'generates consistent checksum for same content' do
        result1 = service.scrape
        result2 = service.scrape

        expect(result1[:checksum]).to eq(result2[:checksum])
      end
    end

    context 'with HTTP error' do
      before do
        stub_request(:get, url).to_return(status: 404, body: 'Not Found')
      end

      it 'returns error result' do
        result = service.scrape

        expect(result[:success]).to be false
        expect(result[:error]).to include('HTTP 404')
        expect(result[:status_code]).to eq(404)
      end
    end

    context 'with timeout error' do
      before do
        stub_request(:get, url).to_timeout
      end

      it 'handles timeout gracefully' do
        result = service.scrape

        expect(result[:success]).to be false
        expect(result[:error]).to eq('Request timeout')
      end
    end

    context 'with network error' do
      before do
        stub_request(:get, url).to_raise(SocketError.new('getaddrinfo: nodename nor servname provided'))
      end

      it 'handles network errors gracefully' do
        result = service.scrape

        expect(result[:success]).to be false
        expect(result[:error]).to include('nodename nor servname provided')
      end
    end
  end

  describe '.scrape_url' do
    it 'creates instance and calls scrape' do
      url = 'https://example.com/terms'
      stub_request(:get, url).to_return(status: 200, body: '<html><title>Test</title></html>')

      result = ScraperService.scrape_url(url)
      expect(result[:success]).to be true
    end
  end

  describe '.scrape_company_documents' do
    let(:company) { create(:company, :twitter_like) }

    before do
      stub_request(:get, company.terms_url)
        .to_return(status: 200, body: '<html><head><title>Terms</title></head><body><h1>Terms of Service</h1></body></html>')
      stub_request(:get, company.privacy_url)
        .to_return(status: 200, body: '<html><head><title>Privacy</title></head><body><h1>Privacy Policy</h1></body></html>')
    end

    it 'scrapes both terms and privacy documents' do
      results = ScraperService.scrape_company_documents(company)

      expect(results.length).to eq(2)

      terms_result = results.find { |r| r[:document_type] == 'terms' }
      privacy_result = results.find { |r| r[:document_type] == 'privacy' }

      expect(terms_result[:success]).to be true
      expect(terms_result[:title]).to eq('Terms')

      expect(privacy_result[:success]).to be true
      expect(privacy_result[:title]).to eq('Privacy')
    end

    it 'handles company with only terms URL' do
      company.update(privacy_url: nil)

      results = ScraperService.scrape_company_documents(company)

      expect(results.length).to eq(1)
      expect(results.first[:document_type]).to eq('terms')
    end
  end

  describe 'content extraction' do
    let(:service) { ScraperService.new('https://example.com') }

    it 'removes script and style elements' do
      html = '<html><body><script>bad</script><style>css</style><p>good</p></body></html>'
      stub_request(:get, 'https://example.com').to_return(status: 200, body: html)

      result = service.scrape
      expect(result[:text]).not_to include('bad')
      expect(result[:text]).not_to include('css')
      expect(result[:text]).to include('good')
    end

    it 'extracts title from h1 if no title tag' do
      html = '<html><body><h1>Main Title</h1><p>Content</p></body></html>'
      stub_request(:get, 'https://example.com').to_return(status: 200, body: html)

      result = service.scrape
      expect(result[:title]).to eq('Main Title')
    end

    it 'prefers title tag over h1' do
      html = '<html><head><title>Page Title</title></head><body><h1>H1 Title</h1></body></html>'
      stub_request(:get, 'https://example.com').to_return(status: 200, body: html)

      result = service.scrape
      expect(result[:title]).to eq('Page Title')
    end

    it 'normalizes whitespace in content' do
      html = <<~HTML
        <html>
          <body>
            <p>Text   with    lots


            of    whitespace</p>
          </body>
        </html>
      HTML
      stub_request(:get, 'https://example.com').to_return(status: 200, body: html)

      result = service.scrape
      expect(result[:text]).to eq('Text with lots of whitespace')
    end
  end

  describe 'security considerations' do
    it 'uses random user agents to avoid detection' do
      service1 = ScraperService.new('https://example.com')
      service2 = ScraperService.new('https://example.com')

      headers1 = service1.instance_variable_get(:@headers)
      headers2 = service2.instance_variable_get(:@headers)

      # User agents should be from the predefined list
      expect(ScraperService::USER_AGENTS).to include(headers1['User-Agent'])
      expect(ScraperService::USER_AGENTS).to include(headers2['User-Agent'])
    end

    it 'respects timeout limits' do
      url = 'https://slow-example.com'
      service = ScraperService.new(url)

      # Mock HTTParty to verify timeout is set
      expect(HTTParty).to receive(:get).with(
        url,
        hash_including(timeout: 30)
      ).and_return(double(success?: true, body: '<html></html>', code: 200))

      service.scrape
    end
  end
end
