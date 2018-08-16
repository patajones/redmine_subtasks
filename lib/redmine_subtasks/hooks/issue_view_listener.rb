###
# Adiciona Callbacks do Plugin Subtasks
# adicionanado elementos visuais nos viwes do controller Issue redmine/app/views/issues
###

module RedmineSubtasks
  class Hooks  < Redmine::Hook::ViewListener

    # Hook view_issues_show_description_bottom � chamado no show da issue, logo abaixo da descri��o
	# cria um novo painel de subtarefas
	render_on :view_issues_show_description_bottom, :partial => "redmine_subtasks/subtasks_tree"	

  end # class
end # module