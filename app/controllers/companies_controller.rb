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
  before_action :set_company, only: [:show, :edit, :update, :destroy, :rearchive]
  
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
      
      successful_archives = archive_results[:results].select { |r| r[:success] }
      failed_archives = archive_results[:results].select { |r| !r[:success] }
      
      if successful_archives.any?
        archived_docs = successful_archives.map { |r| r[:document_type] }.join(' and ')
        success_message = "Company created successfully! We've archived their #{archived_docs}."
        
        if failed_archives.any?
          # Partial success - show both success and warnings
          warnings = failed_archives.map do |result|
            doc_type = case result[:document_type]
                      when 'terms' then 'terms of service'
                      when 'privacy' then 'privacy policy'
                      else result[:document_type]
                      end
            "Warning: Failed to archive #{doc_type}"
          end.join('. ')
          
          redirect_to @company, notice: "#{success_message} #{warnings}."
        else
          # Complete success
          redirect_to @company, notice: success_message
        end
      else
        # Complete failure
        error_messages = archive_results[:errors].map do |error|
          if error.include?('HTTP 429') || error.include?('Too Many Requests')
            'Rate limited - Please try again later'
          else
            error
          end
        end
        redirect_to @company, alert: "Company created but archiving failed: #{error_messages.join(', ')}"
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
  
  def rearchive
    archiver = DocumentArchiverService.new(@company)
    archive_results = archiver.archive_all
    
    if archive_results[:success]
      successful_archives = archive_results[:results].select { |r| r[:success] }
      count = successful_archives.length
      redirect_to @company, notice: "Documents re-archived successfully. #{count} document(s) updated"
    else
      error_messages = archive_results[:errors].map do |error|
        if error.include?('HTTP 429') || error.include?('Too Many Requests')
          'Rate limited - Please try again later'
        else
          error
        end
      end
      redirect_to @company, alert: "Re-archiving failed: #{error_messages.join(', ')}"
    end
  end
  
  private
  
  def set_company
    @company = Company.find(params[:id])
  end
  
  def company_params
    params.require(:company).permit(:name, :domain, :terms_url, :privacy_url, :description)
  end
end
