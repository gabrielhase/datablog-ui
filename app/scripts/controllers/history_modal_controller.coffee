angular.module('ldEditor').controller 'HistoryModalController',
class HistoryModalController

  constructor: (@$scope, @$modalInstance, @snippet, @documentService, @editorService, @uiStateService) ->
    @$scope.close = (event) => @close(event)
    @$scope.snippet = @snippet
    @documentService.getHistory(@editorService.getCurrentDocument().id, @snippet.id).then (history) =>
      @$scope.history = history


  close: (event) ->
    @$modalInstance.dismiss('close')
    event.stopPropagation() # so sidebar selection is not lost
