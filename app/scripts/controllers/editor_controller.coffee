# Parent scope of the editor app.
angular.module('ldEditor').controller 'EditorController',
class EditorController

  constructor: (@$scope, @dialogService, @uiStateService, @snippetInsertService, @editableEventsService) ->
    # editor watches for ui state changes
    @$scope.state = @uiStateService.state

    # bounding box is used for text popover placement
    @$scope.textPopoverBoundingBox = @editableEventsService.currentTextSelectionPos

    # watchers
    @watchInsertMode()


  watchInsertMode: () ->
    @$scope.$watch('state.insertMode', (newVal, oldVal, scope) =>
      insertModeState = @uiStateService.state.insertMode
      if insertModeState.active
        @snippetInsertService.activateInsertMode(scope, insertModeState)
      else
        @snippetInsertService.deactivateInsertMode()
    )
