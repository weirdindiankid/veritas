require 'rails_helper'

RSpec.describe Archive, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      archive = build(:archive)
      expect(archive).to be_valid
    end

    it 'requires a version' do
      archive = build(:archive)
      # Skip the callback and set version to nil directly
      archive.define_singleton_method(:set_version) {}
      archive.version = nil
      expect(archive).not_to be_valid
      expect(archive.errors[:version]).to include("can't be blank")
    end

    it 'requires a checksum' do
      archive = build(:archive, checksum: nil)
      expect(archive).not_to be_valid
      expect(archive.errors[:checksum]).to include("can't be blank")
    end

    it 'requires archived_by' do
      archive = build(:archive, archived_by: nil)
      expect(archive).not_to be_valid
      expect(archive.errors[:archived_by]).to include("can't be blank")
    end

    it 'requires unique version per document' do
      document = create(:document)
      create(:archive, document: document, version: 1)
      archive = build(:archive, document: document, version: 1)
      expect(archive).not_to be_valid
      expect(archive.errors[:version]).to include("has already been taken")
    end

    it 'allows same version for different documents' do
      document1 = create(:document)
      document2 = create(:document)
      create(:archive, document: document1, version: 1)
      archive = build(:archive, document: document2, version: 1)
      expect(archive).to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to a document' do
      expect(Archive.reflect_on_association(:document).macro).to eq :belongs_to
    end

    it 'belongs to a previous_archive optionally' do
      association = Archive.reflect_on_association(:previous_archive)
      expect(association.macro).to eq :belongs_to
      expect(association.options[:optional]).to be true
    end
  end

  describe 'scopes' do
    let(:document) { create(:document) }
    
    describe '.by_document' do
      it 'returns archives for a specific document' do
        archive1 = create(:archive, document: document)
        archive2 = create(:archive, document: create(:document))
        
        result = Archive.by_document(document)
        expect(result).to include(archive1)
        expect(result).not_to include(archive2)
      end
    end

    describe '.ordered' do
      it 'returns archives ordered by version' do
        archive3 = create(:archive, document: document, version: 3)
        archive1 = create(:archive, document: document, version: 1)
        archive2 = create(:archive, document: document, version: 2)
        
        result = Archive.ordered
        expect(result.map(&:version)).to eq([1, 2, 3])
      end
    end
  end

  describe 'callbacks' do
    describe '#set_version' do
      it 'automatically sets version to 1 for first archive' do
        document = create(:document)
        archive = build(:archive, document: document, version: nil)
        
        expect { archive.save! }.to change { archive.version }.to(1)
      end

      it 'increments version for subsequent archives' do
        document = create(:document)
        create(:archive, document: document, version: 1)
        create(:archive, document: document, version: 2)
        
        archive = build(:archive, document: document, version: nil)
        expect { archive.save! }.to change { archive.version }.to(3)
      end

      it 'does not override manually set version' do
        document = create(:document)
        archive = build(:archive, document: document, version: 5)
        
        expect { archive.save! }.not_to change { archive.version }
        expect(archive.version).to eq(5)
      end
    end
  end

  describe '#has_changes?' do
    it 'returns true when diff_content is present' do
      archive = build(:archive, :with_changes)
      expect(archive.has_changes?).to be true
    end

    it 'returns false when diff_content is nil' do
      archive = build(:archive, :no_changes)
      expect(archive.has_changes?).to be false
    end

    it 'returns false when diff_content is empty string' do
      archive = build(:archive, diff_content: '')
      expect(archive.has_changes?).to be false
    end
  end

  describe '#next_archive' do
    let(:document) { create(:document) }
    
    it 'returns the next version archive' do
      archive1 = create(:archive, document: document, version: 1)
      archive2 = create(:archive, document: document, version: 2)
      
      expect(archive1.next_archive).to eq(archive2)
    end

    it 'returns nil when no next archive exists' do
      archive = create(:archive, document: document, version: 1)
      expect(archive.next_archive).to be_nil
    end

    it 'skips gaps in version numbers' do
      archive1 = create(:archive, document: document, version: 1)
      archive3 = create(:archive, document: document, version: 3)
      
      expect(archive1.next_archive).to be_nil
    end
  end

  describe 'factory' do
    it 'creates a valid archive' do
      archive = create(:archive)
      expect(archive).to be_persisted
      expect(archive.version).to be_present
      expect(archive.checksum).to be_present
      expect(archive.archived_by).to be_present
    end

    it 'creates archive with changes trait' do
      archive = create(:archive, :with_changes)
      expect(archive.has_changes?).to be true
    end

    it 'creates archive with no changes trait' do
      archive = create(:archive, :no_changes)
      expect(archive.has_changes?).to be false
    end
  end
end
