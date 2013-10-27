angular.module('ldEditor').controller 'DataModalController',
class DataModalController

  constructor: (@$scope, @$modalInstance, @highlightedRows) ->
    @$scope.close = (event) => @close(event)


  close: (event) ->
    @$modalInstance.dismiss('close')
    event.stopPropagation() # so sidebar selection is not lost

