class AddIndexesToCompanies < ActiveRecord::Migration[7.2]
  def change
    add_index :companies, :domain, unique: true
    add_index :companies, :name
  end
end
