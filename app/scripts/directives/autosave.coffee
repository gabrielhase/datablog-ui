angular.module('ldEditor').directive 'autosave', (pageStateService, $timeout) ->

  autosavePaused = false

  (scope, element, attrs) ->

    attrs.$observe 'autosavePaused', (val) ->
      autosavePaused = scope.$eval(val)

    hideAfterTimeout = ->
      $timeout(
        -> scope.autosave = {}
        4000
      )

    showMessage = (arg) ->
      for state, message of arg
        scope.autosave =
          state: state
          message: message
      hideAfterTimeout()

    pageStateService.onSuccessfulSave.add ->
      showMessage(success: 'Document saved.')

    pageStateService.onFailedSave.add (reason) ->
      showMessage(failure: reason)

    doc.changed ->
      if !autosavePaused
        pageStateService.dirty()
