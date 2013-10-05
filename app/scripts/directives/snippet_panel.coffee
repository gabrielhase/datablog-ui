angular.module('ldEditor').directive 'snippetPanel', ->

  return {
    restrict: 'A'
    scope: {}
    template: htmlTemplates.snippetPanel
    replace: true
    controller: 'SnippetPanelController'
    require: '^sidebar'
    link: (scope, element, attrs, SidebarController) ->
      # Define upwards API
      scope.hideSidebar = => SidebarController.hideSidebar('snippetPanel')
  }
