angular.module('ldEditor').directive 'popover', ->

  return {
    restrict: 'A'
    scope: {
      'boundingBox': '@'
    }
    transclude: true
    template: angularTemplates.popover
    controller: 'PopoverController'
    link: (scope, element, attrs) ->

      $container = $(element).find('.upfront-popover-panel')
      $container.on 'click.livingdocs', (event) ->
        event.stopPropagation()
        event.preventDefault()

      attrs.$observe 'boundingBox', (val) ->
        box = scope.$eval(val) # not to evaluate a literal
        scope.left = box.left + (box.width / 2) - ($container.outerWidth() / 2)
        scope.top = box.top - $container.outerHeight() - 15
  }
