###
# Adiciona Callbacks do Plugin Subtasks
# adicionanado elementos visuais nos viwes do controller Issue redmine/app/views/issues
###

module RedmineSubtasks
  class Hooks  < Redmine::Hook::ViewListener

    # Hook view_issues_show_description_bottom é chamado no show da issue, logo abaixo da descrição
	# cria um novo painel de subtarefas
	#if Setting.plugin_redmine_subtasks.with_indifferent_access[:subtasks_on_versions] == 'true'
      render_on :view_projects_roadmap_version_bottom, :partial => "redmine_subtasks/version_issues"	
	#end

  end # class
end # module

