# NOTE: The arrow-distance is a coupling to the css rule .upfront-popover .arrow
# outerHeight does not work in this case probably since we are using a css :after
angular.module('ldEditor').directive 'popover', ($timeout) ->

  return {
    restrict: 'A'
    scope: {
      'boundingBox': '@'
      'openCondition': '='
      'placement': '@'
      'arrowDistance': '@'
      'popoverCssClass': '@'
    }
    transclude: true
    template: htmlTemplates.popover
    controller: 'PopoverController'
    link: (scope, element, attrs) ->
      $container = $(element).find('.upfront-popover-panel')

      if attrs.popoverCssClass
        $container.addClass(attrs.popoverCssClass)

      attrs.$observe 'boundingBox', (val) ->
        $timeout ->
          arrowHeight = +scope.arrowDistance
          popoverHeight = $('.upfront-popover').height() + arrowHeight
          popoverWidth = $('.upfront-popover').width()
          box = scope.$eval(val) # not to evaluate a literal
          if box.top < popoverHeight # force the placement to bottom if at the top
            placementOverwrite = 'bottom'

          containerOuterWidth = $container.outerWidth()
          left = box.left - (containerOuterWidth / 2) + (box.width / 2)

          # make sure the popover does not spill out of the document
          padding = 5
          rightBorder = $(window.document.body).width()
          if (left + containerOuterWidth) > (rightBorder - padding)
            left = rightBorder - padding - containerOuterWidth

          left = padding if left < padding

          switch (placementOverwrite || scope.placement)
            when 'bottom'
              scope.left = left
              scope.top = box.bottom + arrowHeight
              scope.arrowCss = 'arrow-top'
            else
              scope.left = left
              scope.top = box.top - $container.outerHeight() - arrowHeight
              scope.arrowCss = 'arrow-bottom'
  }
