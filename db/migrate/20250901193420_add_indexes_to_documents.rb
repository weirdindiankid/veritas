class AddIndexesToDocuments < ActiveRecord::Migration[7.2]
  def change
    add_index :documents, :url
    add_index :documents, :document_type
    add_index :documents, :archived_at
    add_index :documents, :ipfs_hash
  end
end
