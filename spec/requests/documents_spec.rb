require 'rails_helper'

RSpec.describe "Documents", type: :request do
  let(:company) { create(:company) }
  let(:document) { create(:document, company: company) }

  describe "GET /index" do
    it "returns http success" do
      get documents_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get document_path(document)
      expect(response).to have_http_status(:success)
    end
  end

end
