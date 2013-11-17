angular.module('ldEditor').controller 'HistoryModalController',
class HistoryModalController

  constructor: (@$scope, @$modalInstance, @snippet, @documentService, @editorService, @uiStateService) ->
    @$scope.close = (event) => @close(event)
    @$scope.snippet = @snippet
    @documentService.getHistory(@editorService.getCurrentDocument().id, @snippet.id).then (history) =>
      @$scope.history = history

    # temporarily disable autosave
    @uiStateService.set('autosave', false)


  close: (event) ->
    # TODO: call save
    # re-enable autosave
    @uiStateService.set('autosave', {})
    @$modalInstance.dismiss('close')
    event.stopPropagation() # so sidebar selection is not lost
