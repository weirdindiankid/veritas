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

class Archive < ApplicationRecord
  belongs_to :document
  belongs_to :previous_archive, class_name: "Archive", optional: true

  validates :version, presence: true, uniqueness: { scope: :document_id }
  validates :checksum, presence: true
  validates :archived_by, presence: true

  scope :by_document, ->(document) { where(document: document) }
  scope :ordered, -> { order(:version) }

  before_validation :set_version, on: :create

  def has_changes?
    diff_content.present?
  end

  def next_archive
    Archive.where(document: document, version: version + 1).first
  end

  private

  def set_version
    return if version.present?

    self.version = (document.archives.maximum(:version) || 0) + 1
  end
end
