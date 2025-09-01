require 'rails_helper'

RSpec.describe "Home", type: :request do
  describe "GET /" do
    it "returns http success" do
      get root_path
      expect(response).to have_http_status(:success)
    end
    
    it "displays homepage content" do
      get root_path
      expect(response.body).to include("Digital Truth Archive")
      expect(response.body).to include("Veritas")
    end
  end
end
