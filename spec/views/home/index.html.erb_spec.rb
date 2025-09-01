require 'rails_helper'

RSpec.describe "home/index.html.erb", type: :view do
  before do
    assign(:companies_count, 42)
    assign(:documents_count, 156)
    assign(:archives_count, 89)
    assign(:recent_documents, [])
    render
  end

  it 'displays the hero section with title' do
    expect(rendered).to include('Digital Truth')
    expect(rendered).to include('Archive')
  end

  it 'shows statistics cards' do
    expect(rendered).to include('42')
    expect(rendered).to include('156') 
    expect(rendered).to include('89')
  end

  it 'includes call-to-action buttons' do
    expect(rendered).to include('Archive a Company')
    expect(rendered).to include('Browse Archive')
  end

  it 'displays feature explanations' do
    expect(rendered).to include('Consumer Protection')
    expect(rendered).to include('Corporate Accountability')
    expect(rendered).to include('Legal Evidence')
  end
end
