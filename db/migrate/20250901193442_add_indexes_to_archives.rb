class AddIndexesToArchives < ActiveRecord::Migration[7.2]
  def change
    add_index :archives, :checksum
    add_index :archives, [ :document_id, :version ], unique: true
    add_index :archives, :created_at
  end
end
