require 'redmine'
require 'redmine_subtasks'

Redmine::Plugin.register :redmine_subtasks do
  name 'Redmine Subtasks Plugin'
  url 'https://github.com/patajones/redmine_subtasks'  
  author 'Bernardes (originalmente rodrigoa)'  
  author_url 'mailto:Grupo SCORP <grupo.scorp@stj.jus.br>?subject=redmine_subtasks'
  description 'Issues on expandable treeviews on version tab'
  version '4.0.0'

  requires_redmine :version_or_higher => '3.0.0'
  
  settings partial: 'settings/redmine_subtasks', default: { 'subtasks_on_issues' => 'false', 'subtasks_on_versions' => 'true' }
end