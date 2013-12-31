angular.module('ldEditor').controller 'MapEditModalController',
class MapEditModalController

  constructor: (@$scope, @$modalInstance, @snippet) ->
    @$scope.close = $.proxy(@close, this)
    @$scope.center = @snippet.data('center')
    @$scope.markers = @snippet.data('markers')


  close: (event) ->
    @snippet.data
      center:
        lat: @$scope.center.lat
        lng: @$scope.center.lng
        zoom: @$scope.center.zoom
    @$modalInstance.dismiss('close')
    event.stopPropagation() # so sidebar selection is not lost
