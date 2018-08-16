###
# Adiciona Callbacks do Plugin Subtasks
###

module RedmineSubtasks
  class Hooks  < Redmine::Hook::ViewListener
	
	# hook view_layouts_base_body_bottom chamado no layout base depois de renderizado o conteúdo antes do footer	
	# nesse caso é utlizado para substituir a arvore de subtarefas pela outra construida na partial subtask_tree
	# a substituição é feita utilizando JQuery 
	#
	# infelizamente nao foi possível utilizar o método content_for na view, 
	# porque não existe um yeld no layout base default do redmine que seja chamado após a contrução das árvores.
	#
    def view_layouts_base_body_bottom(context={ })
	  str = ""
	  if (context[:controller].class.name == "IssuesController") && (Setting.plugin_redmine_subtasks.with_indifferent_access[:subtasks_on_issues] == 'true')
	    Rails::logger.debug "PluginSubtasks: alterar local da arvore na Issue" 
		str <<%q{		
		<script>
		if ( $( "#issue_tree" ).length ) {
			if ( $( "#issue_tree form" ).length ) {  	  
			  $("#issue_tree form").html($("#issue_tree2 form").html());
			  $("#issue_tree2").remove();
			} else {	  
			  $("#issue_tree").append($("#issue_tree2 form"));
			  $("#issue_tree2").remove();	
			}  
		} else {
			$("#issue_tree2").insertBefore("<hr>");
			$("#issue_tree2").removeAttr("style");
			$("#issue_tree2").attr("id") = "issue_tree";
		}		
		</script>
		}		
	  end unless context[:controller].nil?
	  
	  if (context[:controller].class.name == "VersionsController") && (Setting.plugin_redmine_subtasks.with_indifferent_access[:subtasks_on_versions] == 'true')
	    controller = context[:controller]
	    ssidebar = controller.render(:partial => "redmine_subtasks/version_issues_sidebar")				
		str << ssidebar[0]
		str <<%q{		
		<script>
		ulTarget = $("[for='completed']" ).parent().parent()
		if (ulTarget.length ) {			
			ulTarget.append($("#new_versions_options").html());
			$("#new_versions_options").remove();			
		} else {
			throw "não foi encontrado a tag label com atributo for='completed'";
		}		
		</script>
		}					
	  end unless context[:controller].nil?	  
	  
	  str
	end	
  end # class
end # module