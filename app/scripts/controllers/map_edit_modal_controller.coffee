angular.module('ldEditor').controller 'MapEditModalController',
class MapEditModalController

  constructor: (@$scope, @$modalInstance, @snippet, @leafletData, @$timeout) ->
    @$scope.close = $.proxy(@close, this)
    @$scope.center = @snippet.data('center')
    @$scope.markers = @snippet.data('markers')

    @$timeout =>
      @leafletData.getMap().then (map) =>
        new L.Control.GeoSearch(
          provider: new L.GeoSearch.Provider.OpenStreetMap()
          showMarker: false
        ).addTo(map)
    , 100


  close: (event) ->
    @snippet.data
      center:
        lat: @$scope.center.lat
        lng: @$scope.center.lng
        zoom: @$scope.center.zoom
    @$modalInstance.dismiss('close')
    event.stopPropagation() # so sidebar selection is not lost
