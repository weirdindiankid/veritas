class AddDocumentTypeToDocuments < ActiveRecord::Migration[7.2]
  def change
    add_column :documents, :document_type, :string
  end
end
