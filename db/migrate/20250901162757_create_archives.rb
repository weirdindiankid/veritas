class CreateArchives < ActiveRecord::Migration[7.2]
  def change
    create_table :archives do |t|
      t.references :document, null: false, foreign_key: true
      t.integer :version
      t.references :previous_archive, null: true, foreign_key: { to_table: :archives }
      t.string :checksum
      t.text :diff_content
      t.string :archived_by

      t.timestamps
    end
  end
end
