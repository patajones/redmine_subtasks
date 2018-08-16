# aplication_helper_patch.rb #
##############################

## add project link to issue link
##### 
module RedmineSubtasks::Patches

  module ApplicationHelperPatch
  
    def self.included(base)
      base.send(:include, InstanceMethods)
	  	  
      base.class_eval do	  	    
		alias_method_chain :link_to_issue, :project
      end
    end
  end

  module InstanceMethods	
	## add project link, if options[:project] is present
	#######
	def link_to_issue_with_project(issue, options={})	  
		title = nil
		subject = nil
		text = options[:tracker] == false ? "##{issue.id}" : "#{issue.tracker} ##{issue.id}"
		if options[:subject] == false
		title = issue.subject.truncate(60)
		else
		subject = issue.subject
		if truncate_length = options[:truncate]
			subject = subject.truncate(truncate_length)
		end
		end
		only_path = options[:only_path].nil? ? true : options[:only_path]
		s = link_to(text, issue_url(issue, :only_path => only_path),
					:class => issue.css_classes, :title => title)
		s << h(": #{subject}") if subject
		s = link_to_project(issue.project, {}, :class => "diff_project") + h(" - ") + s if options[:project]
		s
	end
  end
end

unless ApplicationHelper.included_modules.include? RedmineSubtasks::Patches::ApplicationHelperPatch
    ApplicationHelper.send(:include, RedmineSubtasks::Patches::ApplicationHelperPatch)
end