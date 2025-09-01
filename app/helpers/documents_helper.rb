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

module DocumentsHelper
  def document_type_badge(document)
    case document.document_type
    when 'terms'
      content_tag :span, 'Terms of Service', class: 'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800'
    when 'privacy'
      content_tag :span, 'Privacy Policy', class: 'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-purple-100 text-purple-800'
    else
      content_tag :span, document.document_type.humanize, class: 'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800'
    end
  end

  def format_checksum(checksum)
    return 'No checksum' if checksum.blank?
    
    content_tag :code, checksum.first(12) + '...', 
                class: 'bg-gray-100 text-gray-800 text-xs font-mono px-1 py-0.5 rounded',
                title: checksum
  end

  def time_ago_with_tooltip(time)
    return 'Unknown' if time.blank?
    
    content_tag :span, time_ago_in_words(time) + ' ago',
                title: time.strftime('%B %d, %Y at %I:%M %p %Z'),
                class: 'cursor-help'
  end

  def archive_count_text(document)
    count = document.archives.count
    "#{count} #{'version'.pluralize(count)}"
  end
end
