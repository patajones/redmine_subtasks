module RedmineSubtasks::Patches
	module VersionsControllerPatch

		def self.included(base) 
			base.send(:include, InstanceMethods)     
			base.extend(ClassMethods)
			base.class_eval do      
				unloadable
				alias_method_chain :index, :subtasks
			end
		end
		
		module ClassMethods
		end	  
		module InstanceMethods    		
			def index_with_subtasks				
				#salvar opções presonalizadas
				if User.current.present?
					#salvar estado dos checkbox de mostrar tarefas filhas
					version_show = params["version_show"]
					unless version_show.nil?
						User.current.pref.others.merge! :version_show => version_show
						User.current.pref.save
					end
				
					#salvar opção de ordenação
					sort_tree_with_date = params.fetch("sort_tree_with_date", "0")
					User.current.pref.others.merge! :sort_tree_with_date => (sort_tree_with_date=="1")
					User.current.pref.save
				end
								
				index_without_subtasks
			end
		end		
	end
end
	
unless VersionsController.included_modules.include? RedmineSubtasks::Patches::VersionsControllerPatch
    VersionsController.send(:include, RedmineSubtasks::Patches::VersionsControllerPatch)
end