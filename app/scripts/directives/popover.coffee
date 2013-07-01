# NOTE: The arrow-distance is a coupling to the css rule .upfront-popover .arrow
# outerHeight does not work in this case probably since we are using a css :after
angular.module('ldEditor').directive 'popover', ->

  return {
    restrict: 'A'
    scope: {
      'boundingBox': '@'
      'openCondition': '='
      'placement': '@'
      'arrowDistance': '@'
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
        arrowHeight = +scope.arrowDistance
        popoverHeight = $('.upfront-popover').height() + arrowHeight
        popoverWidth = $('.upfront-popover').width()
        box = scope.$eval(val) # not to evaluate a literal
        if box.top < popoverHeight # force the placement to bottom if at the top
          placementOverwrite = 'bottom'

        switch (placementOverwrite || scope.placement)
          when 'bottom'
            scope.left = box.left - ($container.outerWidth() / 2) + (box.width / 2)
            scope.top = box.bottom + arrowHeight
            scope.arrowCss = 'arrow-top'
          else
            scope.left = box.left - ($container.outerWidth() / 2) + (box.width / 2)
            scope.top = box.top - $container.outerHeight() - arrowHeight
            scope.arrowCss = 'arrow-bottom'
  }
