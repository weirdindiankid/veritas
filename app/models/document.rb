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
