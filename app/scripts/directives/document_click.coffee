angular.module('ldEditor').directive('documentClick', [
  '$document'
  'docObserverService'
  ($document, docObserverService) ->

    (scope, element, attrs) ->
      $document.on "click.livingdocs", ->
        scope.$apply(
          docObserverService.click.fire()
        )
])