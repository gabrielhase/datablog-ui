angular.module('ldEditor').controller 'MapEditModalController',
class MapEditModalController

  constructor: (@$scope, @$modalInstance, @snippet, @leafletData, @$timeout, @leafletEvents) ->
    @$scope.close = $.proxy(@close, this)
    @$scope.addMarker = $.proxy(@addMarker, this)
    @$scope.center = @snippet.data('center')
    @$scope.markers = @snippet.data('markers')
    @$scope.editState = {}

    @addGeosearch()
    @setupMapEvents()


  addGeosearch: ->
    @$timeout =>
      @leafletData.getMap().then (map) =>
        new L.Control.GeoSearch(
          provider: new L.GeoSearch.Provider.OpenStreetMap()
          showMarker: false
        ).addTo(map)
    , 100


  setupMapEvents: ->
    @$scope.events =
      map:
        enable: ['click']
      markers:
        enable: ['click']

    @$scope.$on 'leafletDirectiveMap.click', (e, args) =>
      @$scope.editState.addMarker = true
      @$scope.editState.boundingBox =
        top: args.leafletEvent.originalEvent.clientY - 7
        bottom: args.leafletEvent.originalEvent.clientY
        left: args.leafletEvent.originalEvent.clientX - 7
        width: 0
      @$scope.editState.geolocation =
        lat: args.leafletEvent.latlng.lat
        lng: args.leafletEvent.latlng.lng

    @$scope.$on 'leafletDirectiveMarker.click', (e, args) =>
      @disableAddMarkerState()


  disableAddMarkerState: ->
    @$scope.editState.addMarker = false


  addMarker: ->
    # NOTE: since the snippet data is a reference to the scope var, we
    # can work with the collection directly. For once the non-deep-copy thing
    # comes in handy :)
    @$scope.markers.push
      lat: @$scope.editState.geolocation.lat
      lng: @$scope.editState.geolocation.lng
      uuid: livingmapsUid.guid()

    @$scope.editState.addMarker = false


  close: (event) ->
    @snippet.data
      center:
        lat: @$scope.center.lat
        lng: @$scope.center.lng
        zoom: @$scope.center.zoom
    @$modalInstance.dismiss('close')
    event.stopPropagation() # so sidebar selection is not lost
