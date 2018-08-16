##########################
# issues_helper_patch.rb #
##########################

## Modifica o helper IssuesHelper, os helpers no rails são utilizados principalmente para montar htmls que podem ser reaproveitados
## 
## As modificações aqui visam alterar a arvore de de subtarefas ao mostrar uma tarefa.
##### 

module RedmineSTJSubtasks::Patches
  module IssuesHelperPatch
    #include ApplicationHelper    
      
  def self.included(base) # :nodoc:    
    base.send(:include, InstanceMethods)     
    base.class_eval do      
      unloadable
      
      # aliasing methods if needed
	  if Redmine::VERSION::MAJOR == 2          
        alias_method_chain :render_issue_subject_with_tree, :stj_r2
	  end		  
	  alias_method_chain :link_to_new_subtask, :stj
    end
  end

  module InstanceMethods        
    
    #Excludes the subtasks that appear at the beginning of the task form
	#mantendo a compatibilidade com o redmine 2
    def render_issue_subject_with_tree_with_stj_r2(issue)
	  logger.info "\e[31mPluginSTJSubtasks: render_issue_subject_with_tree_with_stj_r2\e[0m"	        
      s = '<div>'
      subject = h(issue.subject)
      if issue.is_private?
        subject = content_tag('span', l(:field_is_private), :class => 'private') + ' ' + subject
      end
      s << content_tag('h3', subject)
      s << '</div>'
      s.html_safe	  
    end

    # o método link_to_new_subtask retorna um html com um link para criação de nova subtarefa
	# no link original, a nova subtarefa já vem como default o tipo sendo o mesmo tipo da tarefa pai, além do pai já vir preenchido
	#
	# o patch altera, incluindo várias novas informações como default. São elas:
	#     Tipo (O primeiro da lista)
	#     Título (o mesmo do pai)	
	#     Descrição (o mesmo do pai)
    #     Tarefa Pai (id do pai)	
	#     Versão (o mesmo do pai)
	#     Categoria (o mesmo do pai)
	#     Atribuido para (o mesmo do pai)
	#
    def link_to_new_subtask_with_stj(issue)		
		logger.debug "\e[31mPluginSTJSubtasks: issue: #{issue.id}: link_to_new_subtask_with_stj\e[0m"	        	  
		s = link_to_new_subtask_without_stj(issue)
		#link para tarefas insternas
		if issue.tracker.sti_type.id == 1		
			internal_add_link = render(:partial => "redmine_stjsubtasks/link_internal_task", :locals => { issue: issue }).html_safe	  
			s << ("&nbsp;/&nbsp".html_safe + internal_add_link) unless internal_add_link.gsub(/\s+/, "").empty?
		end unless issue.tracker.sti_type.nil?
		s		
    end
    
  end # InstanceMethods
end
end


# now we should include this module in ApplicationHelper module
unless IssuesHelper.included_modules.include? RedmineSTJSubtasks::Patches::IssuesHelperPatch
    IssuesHelper.send(:include, RedmineSTJSubtasks::Patches::IssuesHelperPatch)
end