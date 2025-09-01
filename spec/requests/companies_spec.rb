require 'rails_helper'

RSpec.describe "Companies", type: :request do
  describe "GET /companies" do
    it "returns http success" do
      get companies_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /companies/:id" do
    it "returns http success" do
      company = create(:company)
      get company_path(company)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /companies/new" do
    it "returns http success" do
      get new_company_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /companies" do
    it "creates a new company with valid params" do
      # Mock the DocumentArchiverService
      archiver = double('DocumentArchiverService')
      allow(DocumentArchiverService).to receive(:new).and_return(archiver)
      allow(archiver).to receive(:archive_all).and_return({
        success: true,
        results: [ { success: true, document_type: 'Terms of Service' } ]
      })

      company_params = {
        company: {
          name: "Test Company",
          domain: "test.com",
          terms_url: "https://test.com/terms",
          description: "A test company"
        }
      }

      expect {
        post companies_path, params: company_params
      }.to change(Company, :count).by(1)

      expect(response).to have_http_status(:redirect)
    end

    it "renders new template with invalid params" do
      company_params = {
        company: {
          name: "",
          domain: "",
          terms_url: ""
        }
      }

      post companies_path, params: company_params
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
