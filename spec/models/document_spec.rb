require 'rails_helper'

RSpec.describe Document, type: :model do
  describe 'validations' do
    let(:company) { create(:company) }

    it 'is valid with valid attributes' do
      document = build(:document, company: company)
      expect(document).to be_valid
    end

    it 'requires a company' do
      document = build(:document, company: nil)
      expect(document).not_to be_valid
      expect(document.errors[:company]).to include("must exist")
    end

    it 'requires a url' do
      document = build(:document, url: nil, company: company)
      expect(document).not_to be_valid
      expect(document.errors[:url]).to include("can't be blank")
    end

    it 'requires a valid url format' do
      document = build(:document, url: 'invalid-url', company: company)
      expect(document).not_to be_valid
      expect(document.errors[:url]).to include("is invalid")
    end

    it 'requires a title' do
      document = build(:document, title: nil, company: company)
      expect(document).not_to be_valid
      expect(document.errors[:title]).to include("can't be blank")
    end

    it 'requires content' do
      document = build(:document, content: nil, company: company)
      expect(document).not_to be_valid
      expect(document.errors[:content]).to include("can't be blank")
    end

    it 'requires an ipfs_hash' do
      document = build(:document, ipfs_hash: nil, company: company)
      expect(document).not_to be_valid
      expect(document.errors[:ipfs_hash]).to include("can't be blank")
    end

    it 'requires a unique ipfs_hash' do
      existing_document = create(:document, company: company)
      document = build(:document, ipfs_hash: existing_document.ipfs_hash, company: company)
      expect(document).not_to be_valid
      expect(document.errors[:ipfs_hash]).to include("has already been taken")
    end

    it 'requires archived_at timestamp' do
      document = build(:document, archived_at: nil, company: company)
      expect(document).not_to be_valid
      expect(document.errors[:archived_at]).to include("can't be blank")
    end
  end

  describe 'associations' do
    it 'belongs to company' do
      expect(Document.reflect_on_association(:company).macro).to eq :belongs_to
    end

    it 'has many archives' do
      expect(Document.reflect_on_association(:archives).macro).to eq :has_many
    end

    it 'destroys associated archives when document is deleted' do
      document = create(:document)
      archive = create(:archive, document: document)

      expect { document.destroy }.to change(Archive, :count).by(-1)
    end
  end

  describe 'scopes' do
    let(:company) { create(:company) }

    describe '.recent' do
      it 'orders documents by archived_at descending' do
        old_document = create(:document, company: company, archived_at: 2.days.ago)
        new_document = create(:document, company: company, archived_at: 1.day.ago)

        expect(Document.recent.first).to eq(new_document)
        expect(Document.recent.last).to eq(old_document)
      end
    end

    describe '.by_company' do
      it 'returns documents for specific company' do
        company1 = create(:company)
        company2 = create(:company)
        doc1 = create(:document, company: company1)
        doc2 = create(:document, company: company2)

        expect(Document.by_company(company1)).to include(doc1)
        expect(Document.by_company(company1)).not_to include(doc2)
      end
    end
  end

  describe 'methods' do
    describe '#latest_archive' do
      it 'returns the most recent archive' do
        document = create(:document)
        old_archive = create(:archive, document: document, version: 1)
        new_archive = create(:archive, document: document, version: 2)

        expect(document.latest_archive).to eq(new_archive)
      end

      it 'returns nil when no archives exist' do
        document = create(:document)
        expect(document.latest_archive).to be_nil
      end
    end

    describe '#current_version' do
      it 'returns archive count plus one' do
        document = create(:document)
        expect(document.current_version).to eq(1)

        create(:archive, document: document)
        expect(document.current_version).to eq(2)

        create(:archive, document: document)
        expect(document.current_version).to eq(3)
      end
    end
  end

  describe 'cryptographic integrity' do
    it 'stores content with IPFS hash for verification' do
      document = create(:document)
      expect(document.ipfs_hash).to be_present
      expect(document.ipfs_hash.length).to be > 40  # IPFS hashes are typically longer
    end

    it 'maintains timestamp precision for legal evidence' do
      document = create(:document, archived_at: Time.current)
      expect(document.archived_at).to be_within(1.second).of(Time.current)
    end
  end
end
