angular.module('ldEditor').controller 'MapKickstartModalController',
class MapKickstartModalController

  constructor: (@$scope, @$modalInstance) ->
    @$scope.close = $.proxy(@close, this)


  close: (event) ->
    @$modalInstance.dismiss('close')
    event.stopPropagation() # so sidebar selection is not lost



