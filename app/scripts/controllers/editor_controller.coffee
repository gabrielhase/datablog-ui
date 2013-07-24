# Parent scope of the editor app.

class EditorController

  angular.module('ldEditor').controller 'EditorController',
    [
      '$scope'
      'documentService'
      'uiStateService'
      'snippetInsertService'
      'editableEventsService'
      EditorController
    ]

  constructor: ($scope, documentService, uiStateService, snippetInsertService, editableEventsService) ->
    # editor watches for ui state changes
    $scope.uiStateService = uiStateService

    # bounding box is used for popover placement
    $scope.boundingBox = editableEventsService.currentTextSelection
    editableEventsService.setup()
    documentService.get()

    # watchers
    @watchInsertMode($scope, snippetInsertService, uiStateService)


  watchInsertMode: (scope, snippetInsertService, uiStateService) ->
    scope.$watch('uiStateService.state.insertMode', (newVal, oldVal, scope) ->
      if insertParams = uiStateService.state.insertMode
        snippetInsertService.activateInsertMode(scope, insertParams)
      else
        snippetInsertService.deactivateInsertMode()
    )
