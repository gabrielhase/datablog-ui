angular.module('ldEditor').controller 'DataModalController',
class DataModalController

  constructor: (@$scope, @$modalInstance, @mapMediatorService, @highlightedRows, @mapId, @mappedColumn) ->
    @$scope.close = (event) => @close(event)

    @snippetModel = @mapMediatorService.getSnippetModel(@mapId)
    @$scope.visualizedData = @snippetModel.data('data')
    @$scope.gridOptions =
      data: 'visualizedData'


  close: (event) ->
    @$modalInstance.dismiss('close')
    event.stopPropagation() # so sidebar selection is not lost

