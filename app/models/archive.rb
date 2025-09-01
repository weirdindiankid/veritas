class Archive < ApplicationRecord
  belongs_to :document
  belongs_to :previous_archive, class_name: 'Archive', optional: true
  
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
