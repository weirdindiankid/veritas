class CreateDocuments < ActiveRecord::Migration[7.2]
  def change
    create_table :documents do |t|
      t.references :company, null: false, foreign_key: true
      t.string :url
      t.string :title
      t.text :content
      t.datetime :archived_at
      t.string :ipfs_hash

      t.timestamps
    end
  end
end
