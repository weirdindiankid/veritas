require 'rails_helper'

RSpec.describe Company, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      company = build(:company)
      expect(company).to be_valid
    end

    it 'requires a name' do
      company = build(:company, name: nil)
      expect(company).not_to be_valid
      expect(company.errors[:name]).to include("can't be blank")
    end

    it 'requires a domain' do
      company = build(:company, domain: nil)
      expect(company).not_to be_valid
      expect(company.errors[:domain]).to include("can't be blank")
    end

    it 'requires a unique domain' do
      create(:company, domain: 'example.com')
      company = build(:company, domain: 'example.com')
      expect(company).not_to be_valid
      expect(company.errors[:domain]).to include("has already been taken")
    end

    it 'requires a terms_url' do
      company = build(:company, terms_url: nil)
      expect(company).not_to be_valid
      expect(company.errors[:terms_url]).to include("can't be blank")
    end

    it 'requires a valid terms_url format' do
      company = build(:company, terms_url: 'invalid-url')
      expect(company).not_to be_valid
      expect(company.errors[:terms_url]).to include("is invalid")
    end

    it 'allows empty privacy_url' do
      company = build(:company, privacy_url: nil)
      expect(company).to be_valid
    end

    it 'requires valid privacy_url format when present' do
      company = build(:company, privacy_url: 'invalid-url')
      expect(company).not_to be_valid
      expect(company.errors[:privacy_url]).to include("is invalid")
    end

    it 'accepts valid privacy_url' do
      company = build(:company, privacy_url: 'https://example.com/privacy')
      expect(company).to be_valid
    end
  end

  describe 'associations' do
    it 'has many documents' do
      expect(Company.reflect_on_association(:documents).macro).to eq :has_many
    end

    it 'destroys associated documents when company is deleted' do
      company = create(:company)
      document = create(:document, company: company)
      
      expect { company.destroy }.to change(Document, :count).by(-1)
    end
  end

  describe 'scopes' do
    describe '.active' do
      it 'returns companies with terms_url' do
        active_company = create(:company)
        inactive_company = create(:company, :inactive)
        
        expect(Company.active).to include(active_company)
        expect(Company.active).not_to include(inactive_company)
      end
    end
  end

  describe 'factory' do
    it 'creates a valid company' do
      company = create(:company)
      expect(company).to be_persisted
      expect(company.name).to be_present
      expect(company.domain).to be_present
      expect(company.terms_url).to be_present
    end
  end
end
