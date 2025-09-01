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

module HomeHelper
  def stats_card(title, value, description, icon_class = "fas fa-chart-line")
    content_tag :div, class: "bg-white overflow-hidden shadow rounded-lg" do
      content_tag :div, class: "p-5" do
        concat(
          content_tag(:div, class: "flex items-center") do
            concat(
              content_tag(:div, class: "flex-shrink-0") do
                content_tag :i, "", class: "#{icon_class} text-2xl text-gray-400"
              end
            )
            concat(
              content_tag(:div, class: "ml-5 w-0 flex-1") do
                concat(content_tag(:dl) do
                  concat(content_tag(:dt, title, class: "text-sm font-medium text-gray-500 truncate"))
                  concat(content_tag(:dd, value, class: "text-lg font-medium text-gray-900"))
                end)
                concat(content_tag(:p, description, class: "text-sm text-gray-500 mt-1")) if description
              end
            )
          end
        )
      end
    end
  end

  def feature_card(title, description, icon_class)
    content_tag :div, class: "relative bg-white p-6 rounded-lg shadow hover:shadow-md transition-shadow" do
      concat(
        content_tag(:div) do
          concat(content_tag(:i, "", class: "#{icon_class} text-3xl text-blue-600 mb-4"))
          concat(content_tag(:h3, title, class: "text-lg font-medium text-gray-900 mb-2"))
          concat(content_tag(:p, description, class: "text-gray-600"))
        end
      )
    end
  end
end
