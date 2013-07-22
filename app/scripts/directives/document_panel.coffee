angular.module('ldEditor').directive 'documentPanel', () ->


  return {
    restrict: 'A'
    scope: {}
    template: angularTemplates.documentPanel
    replace: true
    controller: 'DocumentPanelController'
    require: '^sidebar' # the ^ enables lookup in the parent directive
    link: (scope, element, attrs, SidebarController) ->
      # Define upwards API
      scope.hideSidebar = SidebarController.hideSidebar
  }
