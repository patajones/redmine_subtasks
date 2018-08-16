module RedmineSubtasks


	def self.issue_compare(a,b)		
		a_closed = a.status.is_closed && a.closed_on.present? ? a.closed_on.utc.to_i : a.due_date.present? ? a.due_date.to_time.to_i : 99999999999
		b_closed = b.status.is_closed && b.closed_on.present? ? b.closed_on.utc.to_i : b.due_date.present? ? b.due_date.to_time.to_i : 99999999999
		if a.start_date != b.start_date
			d1 = a.start_date.present? ? a.start_date.jd : 9999999
			d2 = b.start_date.present? ? b.start_date.jd : 9999999		
		elsif a_closed != b_closed
			d1 = a_closed
			d2 = b_closed
		else
			d1 = a.id
			d2 = b.id
		end
		d1 <=> d2	
	end

end

require 'redmine_subtasks/patches/versions_helper_patch'
require 'redmine_subtasks/patches/application_helper_patch'
require 'redmine_subtasks/patches/versions_controller_patch'

require 'redmine_subtasks/hooks/base_view_listener'
require 'redmine_subtasks/hooks/issue_view_listener'
require 'redmine_subtasks/hooks/version_view_listener'
