require 'rails_helper'

RSpec.describe HomeHelper, type: :helper do
  describe '#stats_card' do
    it 'renders a stats card with title, value and description' do
      card = helper.stats_card('Companies', '42', 'Total companies archived')
      
      expect(card).to include('Companies')
      expect(card).to include('42')
      expect(card).to include('Total companies archived')
      expect(card).to include('bg-white overflow-hidden shadow rounded-lg')
    end

    it 'uses default icon when none provided' do
      card = helper.stats_card('Test', '1', 'Description')
      
      expect(card).to include('fas fa-chart-line')
    end

    it 'uses custom icon when provided' do
      card = helper.stats_card('Test', '1', 'Description', 'fas fa-users')
      
      expect(card).to include('fas fa-users')
    end

    it 'handles missing description gracefully' do
      card = helper.stats_card('Test', '1', nil)
      
      expect(card).to include('Test')
      expect(card).to include('1')
      expect(card).not_to include('<p')
    end
  end

  describe '#feature_card' do
    it 'renders a feature card with title, description and icon' do
      card = helper.feature_card(
        'IPFS Integration',
        'Immutable storage with cryptographic guarantees',
        'fas fa-lock'
      )
      
      expect(card).to include('IPFS Integration')
      expect(card).to include('Immutable storage with cryptographic guarantees')
      expect(card).to include('fas fa-lock')
      expect(card).to include('bg-white p-6 rounded-lg shadow hover:shadow-md')
    end

    it 'applies correct styling classes' do
      card = helper.feature_card('Title', 'Description', 'icon-class')
      
      expect(card).to include('text-3xl text-blue-600 mb-4')
      expect(card).to include('text-lg font-medium text-gray-900 mb-2')
      expect(card).to include('text-gray-600')
    end
  end
end
