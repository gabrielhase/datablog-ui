# Parent scope of the editor app.
class EditorController


  constructor: ($scope, currentDocumentService, uiStateService, snippetInsertService, editableEventsService) ->
    # editor watches for ui state changes
    $scope.uiStateService = uiStateService

    # bounding box is used for popover placement
    $scope.boundingBox = editableEventsService.currentTextSelection
    editableEventsService.setup()
    currentDocumentService.get()

    # watchers
    @watchInsertMode($scope, snippetInsertService, uiStateService)


  watchInsertMode: (scope, snippetInsertService, uiStateService) ->
    scope.$watch('uiStateService.state.insertMode', (newVal, oldVal, scope) ->
      if insertParams = uiStateService.state.insertMode
        snippetInsertService.activateInsertMode(scope, insertParams)
      else
        snippetInsertService.deactivateInsertMode()
    )


angular.module('ldEditor').controller(
  'EditorController'
  [
    '$scope'
    'currentDocumentService'
    'uiStateService'
    'snippetInsertService'
    'editableEventsService'
    EditorController
  ]
)
