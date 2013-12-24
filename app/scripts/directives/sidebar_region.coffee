angular.module('ldEditor').directive 'sidebarRegion', ->

  return {
    restrict: 'A'
    scope:
      "caption": "@"
      "validityCondition": "@"
      "checkValidity": "@"
    template: htmlTemplates.sidebarRegion
    replace: true
    transclude: true
    link: (scope, element, attrs) ->

      scope.showContent = true

      if scope.checkValidity
        attrs.$observe 'validityCondition', (value) ->
          if value
            scope.iconClass = 'entypo-check upfront-check'
          else
            scope.iconClass = 'entypo-attention upfront-important'

      scope.toggle = ->
        scope.showContent = !scope.showContent
  }
