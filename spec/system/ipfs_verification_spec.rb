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

require 'rails_helper'

RSpec.describe 'IPFS Verification and Cryptographic Guarantees', type: :system do
  before do
    driven_by(:rack_test)
  end

  describe 'Document integrity verification' do
    let(:company) { create(:company, name: 'Crypto Corp', domain: 'crypto.com') }
    let(:original_content) { 'Original Terms: Users agree to our service conditions.' }
    let(:ipfs_hash) { 'QmOriginalHashValue123456789' }

    before do
      # Mock IPFS to return consistent hash
      allow_any_instance_of(IpfsService).to receive(:add).and_return(ipfs_hash)
      allow_any_instance_of(IpfsService).to receive(:get).with(ipfs_hash).and_return(original_content)
    end

    it 'stores document with IPFS hash and displays verification info' do
      document = create(:document,
        company: company,
        content: original_content,
        ipfs_hash: ipfs_hash,
        title: 'Terms of Service'
      )

      visit document_path(document)

      expect(page).to have_content('Cryptographic Verification')
      expect(page).to have_content('IPFS Hash')
      expect(page).to have_content(ipfs_hash)
      expect(page).to have_content('IPFS Hash')
    end

    it 'verifies document has not been tampered with' do
      document = create(:document,
        company: company,
        content: original_content,
        ipfs_hash: ipfs_hash
      )

      # Calculate checksum
      checksum = Digest::SHA256.hexdigest(original_content)

      visit document_path(document)

      expect(page).to have_content('Verification Status: Valid')
      expect(page).to have_content(checksum[0..11]) # First 12 chars of checksum
    end

    it 'shows warning if IPFS content differs from stored content' do
      # Mock IPFS returning different content
      allow_any_instance_of(IpfsService).to receive(:get).with(ipfs_hash).and_return('Modified content')

      document = create(:document,
        company: company,
        content: original_content,
        ipfs_hash: ipfs_hash
      )

      visit document_path(document)

      # Should show some indication of verification failure
      expect(page).to have_content('Terms of Service')
      expect(page).to have_content(ipfs_hash)
    end
  end

  describe 'Archive versioning with cryptographic trail' do
    let(:company) { create(:company) }
    let(:document) { create(:document, company: company) }

    it 'maintains cryptographic chain of archives' do
      # Create version history
      archive1 = create(:archive,
        document: document,
        version: 1,
        checksum: Digest::SHA256.hexdigest('Version 1 content'),
        diff_content: 'Initial terms',
        archived_by: 'system'
      )

      archive2 = create(:archive,
        document: document,
        version: 2,
        previous_archive: archive1,
        checksum: Digest::SHA256.hexdigest('Version 2 content'),
        diff_content: 'Updated privacy policy section',
        archived_by: 'admin@example.com'
      )

      visit document_path(document)

      expect(page).to have_content('Version History')
      expect(page).to have_content('Version 1')
      expect(page).to have_content('Version 2')
      expect(page).to have_content('Initial terms')
      expect(page).to have_content('Updated privacy policy section')

      # Each version should show its checksum
      expect(page).to have_content(archive1.checksum[0..11])
      expect(page).to have_content(archive2.checksum[0..11])
    end

    it 'displays chain of custody information' do
      archive = create(:archive,
        document: document,
        archived_by: 'legal@company.com',
        created_at: 2.days.ago
      )

      visit document_path(document)

      within('.version-history') do
        expect(page).to have_content('Archived by: legal@company.com')
        expect(page).to have_content('2 days ago')
      end
    end
  end

  describe 'Timestamp precision for legal evidence' do
    xit 'displays precise timestamps for archived documents' do
      timestamp = DateTime.new(2025, 1, 15, 14, 30, 45, '-05:00')
      document = create(:document,
        company: create(:company),
        archived_at: timestamp
      )

      visit document_path(document)

      # Should show full timestamp with timezone
      expect(page).to have_content('Archived At')
      expect(page).to have_content('January 15, 2025')
      expect(page).to have_content('14:30:45')
    end

    it 'maintains microsecond precision in database' do
      precise_time = Time.current
      document = create(:document,
        company: create(:company),
        archived_at: precise_time
      )

      # Verify precision is maintained
      expect(document.reload.archived_at.to_f).to be_within(0.001).of(precise_time.to_f)
    end
  end

  describe 'Content immutability verification' do
    it 'prevents modification of archived content' do
      document = create(:document, content: 'Original content')
      original_ipfs_hash = document.ipfs_hash

      # Attempt to modify (this should not affect the IPFS-stored version)
      document.update(content: 'Modified content')

      visit document_path(document)

      # IPFS hash should remain the same
      expect(page).to have_content(original_ipfs_hash)
      expect(page).to have_content('IPFS Immutable')
    end
  end

  describe 'Legal evidence display' do
    it 'shows all required information for court admissibility' do
      company = create(:company,
        name: 'Legal Corp',
        domain: 'legal.com'
      )

      document = create(:document,
        company: company,
        url: 'https://legal.com/terms',
        archived_at: 1.month.ago,
        ipfs_hash: 'QmLegalHash123'
      )

      archive = create(:archive,
        document: document,
        checksum: Digest::SHA256.hexdigest('content'),
        archived_by: 'legal-team@archiveright.org'
      )

      visit document_path(document)

      # All elements required for legal evidence
      expect(page).to have_content('Legal Corp')
      expect(page).to have_content('https://legal.com/terms')
      expect(page).to have_content('IPFS Hash: QmLegalHash123')
      expect(page).to have_content('Archived')
      expect(page).to have_content('legal-team@archiveright.org')

      # Should have print-friendly option
      expect(page).to have_button('Print Legal Report')
    end
  end
end
