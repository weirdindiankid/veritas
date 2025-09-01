# Veritas - Corporate Terms of Service Digital Archive
# Copyright (C) 2025 Dharmesh Tarapore <dharmesh@tarapore.ca>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

class CompaniesController < ApplicationController
  before_action :set_company, only: [:show, :edit, :update, :destroy]
  
  def index
    @companies = Company.all.includes(:documents).order(:name)
  end

  def show
    @documents = @company.documents.recent.limit(10)
  end

  def new
    @company = Company.new
  end

  def create
    @company = Company.new(company_params)
    
    if @company.save
      # Automatically archive documents
      archiver = DocumentArchiverService.new(@company)
      archive_results = archiver.archive_all
      
      if archive_results[:success]
        successful_archives = archive_results[:results].select { |r| r[:success] }
        archived_docs = successful_archives.map { |r| r[:document_type] }.join(' and ')
        redirect_to @company, notice: "Company created successfully! We've archived their #{archived_docs}."
      else
        redirect_to @company, alert: "Company created but archiving failed: #{archive_results[:errors].join(', ')}"
      end
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
  end
  
  def update
    if @company.update(company_params)
      redirect_to @company, notice: 'Company was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @company.destroy
    redirect_to companies_url, notice: 'Company was successfully deleted.'
  end
  
  private
  
  def set_company
    @company = Company.find(params[:id])
  end
  
  def company_params
    params.require(:company).permit(:name, :domain, :terms_url, :privacy_url, :description)
  end
end
