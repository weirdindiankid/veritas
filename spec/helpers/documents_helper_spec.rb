require 'rails_helper'

RSpec.describe DocumentsHelper, type: :helper do
  describe '#document_type_badge' do
    it 'returns Terms of Service badge for terms document' do
      document = build(:document, document_type: 'terms')
      badge = helper.document_type_badge(document)
      
      expect(badge).to include('Terms of Service')
      expect(badge).to include('bg-blue-100 text-blue-800')
    end

    it 'returns Privacy Policy badge for privacy document' do
      document = build(:document, document_type: 'privacy')
      badge = helper.document_type_badge(document)
      
      expect(badge).to include('Privacy Policy')
      expect(badge).to include('bg-purple-100 text-purple-800')
    end

    it 'returns generic badge for other document types' do
      document = build(:document, document_type: 'cookie_policy')
      badge = helper.document_type_badge(document)
      
      expect(badge).to include('Cookie policy')
      expect(badge).to include('bg-gray-100 text-gray-800')
    end
  end

  describe '#format_checksum' do
    it 'returns truncated checksum with tooltip' do
      checksum = 'a1b2c3d4e5f6789012345678901234567890abcdef'
      formatted = helper.format_checksum(checksum)
      
      expect(formatted).to include('a1b2c3d4e5f6...')
      expect(formatted).to include("title=\"#{checksum}\"")
      expect(formatted).to include('bg-gray-100 text-gray-800 text-xs font-mono')
    end

    it 'returns "No checksum" when blank' do
      expect(helper.format_checksum(nil)).to eq('No checksum')
      expect(helper.format_checksum('')).to eq('No checksum')
    end

    it 'handles short checksums' do
      checksum = 'short'
      formatted = helper.format_checksum(checksum)
      
      expect(formatted).to include('short...')
    end
  end

  describe '#time_ago_with_tooltip' do
    it 'returns time ago with formatted tooltip' do
      time = 2.hours.ago
      result = helper.time_ago_with_tooltip(time)
      
      expect(result).to include('2 hours ago')
      expect(result).to include('title=')
      expect(result).to include('cursor-help')
    end

    it 'returns "Unknown" for blank time' do
      expect(helper.time_ago_with_tooltip(nil)).to eq('Unknown')
      expect(helper.time_ago_with_tooltip('')).to eq('Unknown')
    end
  end

  describe '#archive_count_text' do
    it 'returns singular form for 1 archive' do
      document = create(:document)
      create(:archive, document: document)
      
      result = helper.archive_count_text(document)
      expect(result).to eq('1 version')
    end

    it 'returns plural form for multiple archives' do
      document = create(:document)
      create_list(:archive, 3, document: document)
      
      result = helper.archive_count_text(document)
      expect(result).to eq('3 versions')
    end

    it 'returns zero versions' do
      document = create(:document)
      
      result = helper.archive_count_text(document)
      expect(result).to eq('0 versions')
    end
  end
end
