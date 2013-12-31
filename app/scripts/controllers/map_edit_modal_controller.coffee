angular.module('ldEditor').controller 'MapEditModalController',
class MapEditModalController

  constructor: (@$scope, @$modalInstance, @snippet, @leafletData, @$timeout, @leafletEvents) ->
    @$scope.close = $.proxy(@close, this)
    @$scope.center = @snippet.data('center')
    @$scope.markers = @snippet.data('markers')
    @$scope.editState = {}

    @$scope.events =
      map:
        enable: @leafletEvents.getAvailableMapEvents()

    @$timeout =>
      @leafletData.getMap().then (map) =>
        new L.Control.GeoSearch(
          provider: new L.GeoSearch.Provider.OpenStreetMap()
          showMarker: false
        ).addTo(map)
    , 100

    @$scope.$on 'leafletDirectiveMap.click', (e, args) =>
      @$scope.editState.addMarker = true
      @$scope.editState.boundingBox =
        top: args.leafletEvent.originalEvent.clientY - 7
        bottom: args.leafletEvent.originalEvent.clientY
        left: args.leafletEvent.originalEvent.clientX - 7
        width: 0


  close: (event) ->
    @snippet.data
      center:
        lat: @$scope.center.lat
        lng: @$scope.center.lng
        zoom: @$scope.center.zoom
    @$modalInstance.dismiss('close')
    event.stopPropagation() # so sidebar selection is not lost
