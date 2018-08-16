# verions_helper_patch.rb #
###########################

## 
## As modificações aqui visam buscar as tarefas pai das tarefas na versão
##### 

module RedmineSubtasks::Patches
  module VersionsHelperPatch
      def self.included(base)
        base.send(:include, InstanceMethods)     
        base.class_eval do      
          unloadable
        end
      end

      module InstanceMethods    
        #cria um array com objetos issues que devem estar na arvore.
		#as subtask estaram no atributo version_children das instancis Issue
        def version_issues_tree(version, version_issues, selected_tracker_ids)
          logger.debug "\e[31mPluginSubtasks: call version_issues_tree\e[0m"
		  #cria um objeto array com um método especial para inserir os objetos
          issues_tree = Array.new
		  def issues_tree.add_issue_with_parent(issue)
		    Rails.logger.debug "\e[31mPluginSubtasks: Array(#{self.collect{|i| i.id}}).add_issue_with_parent(#{issue.id})\e[0m"
		    return if self.include? issue			
			
			#verifica ser tem um root alcancável. o método de verificação de root foi incrementado 
			#pois foi encontrado na base do STJ dados estranhos que causavam erro na funcionalidade
			is_root = issue.root?
			unless is_root
			  Rails.logger.debug "PluginSubtasks: #{issue.id} NÃO é root. busca root..."
			  r = issue.ancestors.first			  
			  root = self.include?(r) ? self[self.index(r)] : r
			  if root.nil? 
			    Rails.logger.warn "PluginSubtasks: WARN: Data of issue #{issue.id} are corrupt. The root issue could not be found. parent_id: #{issue.parent_id}, root_id: #{issue.root_id}"
			    is_root = true
			  else Rails.logger.debug "PluginSubtasks: root definido: #{root}"
			  end
			end
			
			if is_root
			  Rails.logger.debug "PluginSubtasks: tratando #{issue.id} como root"
			  RedmineSubtasks::Patches.add_module_version_tree_module_to_issue issue
			  self << issue			  
			else			  
			  RedmineSubtasks::Patches.add_module_version_tree_module_to_issue root			  			  
			  root.add_version_child issue			  
			  self << root unless self.include?(root)
            end						  
		  end
		  	  
          add_issues_other_project = User.current.nil? ? false : User.current.pref.others.fetch(:version_show, "child_none") != "child_none"
		  
		  version_issues.each do |issue|		    
			RedmineSubtasks::Patches.add_module_version_tree_module_to_issue issue			
			issue.add_clear_version_child version, add_issues_other_project  
		    issues_tree.add_issue_with_parent issue
		  end
		  
		  if User.current.pref.others.fetch(:sort_tree_with_date, false)
			logger.debug "\e[31mPluginSubtasks: sort issues_tree\e[0m"
			issues_tree.sort! { |a, b| RedmineSubtasks.issue_compare(a,b) }
			issues_tree.each { |i| i.sort_version_children if i.respond_to?("sort_version_children") }					  
		  end
		  
		  logger.debug "\e[31mPluginSubtasks: returning version_issues_tree\e[0m: #{issues_tree}"
          return issues_tree
        end
      end # InstanceMethods
	end
	
    def self.add_module_version_tree_module_to_issue(issue)
	  Rails.logger.debug "\e[31mPluginSubtasks: call add_module_version_tree_module_to_issue(#{issue})\e[0m"
	  #aplica modulo na instancia do objeto issue,
	  #assim adiciona novos métodos apenas nessa instancia
	  issue.extend(RedmineSubtasks::Patches::IssueVersionTreeMethods) unless issue.singleton_class.included_modules.include? RedmineSubtasks::Patches::IssueVersionTreeMethods	
	end
	
	module IssueVersionTreeMethods
	    @version_children = nil
	    def self.extended(base) 
	      Rails.logger.debug "including module on #{base}"
		  raise "Module can only be extended on class Issue. (actual class #{base.class})" if base.class != Issue
	    end
	  	
    	def version_children
    	  @version_children ||= Array.new
    	  return @version_children
    	end
    	  
		#adiciona a issue do parametro no campo version_children, incluindo toda a arvore ancestral caso não seja filha imediata.		  
    	def add_version_child(issue)  
          Rails.logger.debug "\e[31mPluginSubtasks: add_version_child. Self: #{self.id}, Issue: #{issue.id}\e[0m"	        		  		  		  					    					  
    	  raise "parameter issue #{issue.id} is not a child of this issue #{self.id}." unless issue.ancestors.include? self		
          if issue.parent == self
		    #caso já exista, aproveitar os filhos que foram passados no parametro
		    if self.version_children.include? issue			    
		      old_issue = self.version_children.find{|i| i.id == issue.id}	
		      issue.version_children.each do |vc|
			    old_issue.version_children << vc unless old_issue.version_children.include?(vc) 				  
			  end
		    else
    	      self.version_children << issue 
		    end	
    	  else    		  			  
		    #buscar filho imeditado, 
    	    vc = issue.ancestors.find{|a| a.parent == self}
            vc = self.version_children.find{|i| i.id == vc.id} if self.version_children.include?(vc)
    	    RedmineSubtasks::Patches.add_module_version_tree_module_to_issue vc
    	    vc.add_version_child issue
            self.version_children << vc unless self.version_children.include?(vc)
    	  end			
    	end
		  
		#adiciona todos as issues descedentes no campo version_children
		#caso seja da mesma versão ou do mesmo projeto ou mesmo todos se parametro add_issues_other_project for verdadeiro
		def add_clear_version_child(origin_version, add_issues_other_project = false)
		  Rails.logger.debug "\e[31mPluginSubtasks: add_clear_version_child. Issue: #{self.id} add_issues_other_project: #{add_issues_other_project}\e[0m"	        		  		  		  					    						
		  self.children.each do |c|			  			  
		    unless self.version_children.include?(c)			  			    			    
		      RedmineSubtasks::Patches.add_module_version_tree_module_to_issue c
			  c.add_clear_version_child(origin_version, User.current.pref.others.fetch(:version_show, "child_none") == "child_all")
		      self.version_children << c								
		    end if add_issues_other_project || c.fixed_version == origin_version || c.project == origin_version.project
		  end unless self.children.nil?
		end
		  
    	def sort_version_children
		  self.version_children.sort! { |a, b| RedmineSubtasks.issue_compare(a,b) }			
		  self.version_children.each { |i| i.sort_version_children if i.respond_to?("sort_version_children") }			
    	end		  	  
	end  

end

# now we should include this module in ApplicationHelper module
unless VersionsHelper.included_modules.include? RedmineSubtasks::Patches::VersionsHelperPatch
    VersionsHelper.send(:include, RedmineSubtasks::Patches::VersionsHelperPatch)
end