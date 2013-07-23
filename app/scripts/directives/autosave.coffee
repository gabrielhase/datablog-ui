angular.module('ldEditor').directive 'autosave',

  (pageStateService, $timeout) ->

    (scope, element, attrs) ->

      pageStateService.onSave.add (response) ->
        scope.serverResponse = response
        $timeout( =>
          scope.serverResponse = undefined
        , 4000)

      doc.changed ->
        pageStateService.dirty()
