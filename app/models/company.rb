class Company < ApplicationRecord
  has_many :documents, dependent: :destroy
  
  validates :name, presence: true
  validates :domain, presence: true, uniqueness: true
  validates :terms_url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp }
  validates :privacy_url, format: { with: URI::DEFAULT_PARSER.make_regexp }, allow_blank: true
  
  scope :active, -> { where.not(terms_url: nil) }
end
