require 'rails_helper'

RSpec.describe CompaniesHelper, type: :helper do
  describe '#company_status_badge' do
    it 'returns active badge when company has terms_url' do
      company = build(:company, terms_url: 'https://example.com/terms')
      badge = helper.company_status_badge(company)
      
      expect(badge).to include('Active')
      expect(badge).to include('bg-green-100 text-green-800')
    end

    it 'returns inactive badge when company has no terms_url' do
      company = build(:company, terms_url: nil)
      badge = helper.company_status_badge(company)
      
      expect(badge).to include('Inactive')
      expect(badge).to include('bg-gray-100 text-gray-800')
    end

    it 'returns inactive badge when terms_url is empty' do
      company = build(:company, terms_url: '')
      badge = helper.company_status_badge(company)
      
      expect(badge).to include('Inactive')
    end
  end

  describe '#format_domain_link' do
    it 'creates a link with https prefix for domain without protocol' do
      link = helper.format_domain_link('example.com')
      
      expect(link).to include('href="https://example.com"')
      expect(link).to include('example.com')
      expect(link).to include('target="_blank"')
      expect(link).to include('rel="noopener noreferrer"')
    end

    it 'uses domain as-is when it already has protocol' do
      link = helper.format_domain_link('https://example.com')
      
      expect(link).to include('href="https://example.com"')
      expect(link).to include('example.com')
    end

    it 'applies correct CSS classes' do
      link = helper.format_domain_link('example.com')
      
      expect(link).to include('text-blue-600 hover:text-blue-800 underline')
    end
  end

  describe '#document_count_text' do
    it 'returns singular form for 1 document' do
      company = create(:company)
      create(:document, company: company)
      
      result = helper.document_count_text(company)
      expect(result).to eq('1 document')
    end

    it 'returns plural form for multiple documents' do
      company = create(:company)
      create_list(:document, 3, company: company)
      
      result = helper.document_count_text(company)
      expect(result).to eq('3 documents')
    end

    it 'returns zero documents' do
      company = create(:company)
      
      result = helper.document_count_text(company)
      expect(result).to eq('0 documents')
    end
  end
end
