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

class Document < ApplicationRecord
  belongs_to :company
  has_many :archives, dependent: :destroy

  validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp }
  validates :title, presence: true
  validates :content, presence: true
  validates :ipfs_hash, presence: true, uniqueness: true
  validates :archived_at, presence: true

  scope :recent, -> { order(archived_at: :desc) }
  scope :by_company, ->(company) { where(company: company) }

  def latest_archive
    archives.order(:version).last
  end

  def current_version
    archives.count + 1
  end
end
