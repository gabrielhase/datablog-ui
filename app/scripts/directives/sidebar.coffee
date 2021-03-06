angular.module('ldEditor').directive 'sidebar', ($compile) ->

    # Directive
    return {
      restrict: 'A'
      scope: {
        'foldedOut': '='
      }
      template: htmlTemplates.sidebar
      replace: true
      transclude: true
      controller: 'SidebarController'
      link: (scope, element, attrs) ->
        # nothing
    }
