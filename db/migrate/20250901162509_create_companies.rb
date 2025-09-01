class CreateCompanies < ActiveRecord::Migration[7.2]
  def change
    create_table :companies do |t|
      t.string :name
      t.string :domain
      t.string :terms_url
      t.string :privacy_url
      t.text :description

      t.timestamps
    end
  end
end
