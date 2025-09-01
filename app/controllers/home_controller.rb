class HomeController < ApplicationController
  def index
    @recent_documents = Document.recent.includes(:company).limit(5)
    @companies_count = Company.count
    @documents_count = Document.count
    @archives_count = Archive.count
  end
end
