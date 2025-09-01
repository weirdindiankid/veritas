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

module CompaniesHelper
  def company_status_badge(company)
    if company.terms_url.present?
      content_tag :span, "Active", class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800"
    else
      content_tag :span, "Inactive", class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800"
    end
  end

  def format_domain_link(domain)
    url = domain.start_with?("http") ? domain : "https://#{domain}"
    link_to domain, url, target: "_blank", rel: "noopener noreferrer", class: "text-blue-600 hover:text-blue-800 underline"
  end

  def document_count_text(company)
    count = company.documents.count
    "#{count} #{'document'.pluralize(count)}"
  end
end
