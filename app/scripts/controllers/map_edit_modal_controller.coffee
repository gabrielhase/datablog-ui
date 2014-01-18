angular.module('ldEditor').controller 'MapEditModalController',
class MapEditModalController

  constructor: (@$scope, @$modalInstance, @snippet, @leafletData, @$timeout, @leafletEvents) ->
    @$scope.close = $.proxy(@close, this)
    @$scope.addMarker = $.proxy(@addMarker, this)
    @$scope.removeMarker = $.proxy(@removeMarker, this)
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
          zoomLevel: 12
        ).addTo(map)
    , 100


  setupMapEvents: ->
    @$scope.events =
      map:
        enable: ['click']
      markers:
        enable: ['click']

    @$scope.$on 'leafletDirectiveMap.click', $.proxy(@mapClick, this)
    @$scope.$on 'leafletDirectiveMarker.click', $.proxy(@markerClick, this)
    for e in ['leafletDirectiveMap.drag', 'leafletDirectiveMap.move', 'leafletDirectiveMap.zoomstart',
    'leafletDirectiveMap.blur']
      @$scope.$on e, (e, args) =>
        @disableMarkerSelectedState(e, args)
        @disableAddMarkerState(e, args)


  mapClick: (e, args) ->
    @disableMarkerSelectedState()
    @$scope.editState.addMarker = true
    @$scope.editState.boundingBox =
      top: args.leafletEvent.originalEvent.clientY - 7
      bottom: args.leafletEvent.originalEvent.clientY - 7
      left: args.leafletEvent.originalEvent.clientX - 7
      width: 0
    @$scope.editState.geolocation =
      lat: args.leafletEvent.latlng.lat
      lng: args.leafletEvent.latlng.lng


  markerClick: (e, args) ->
    @disableAddMarkerState()
    marker = @$scope.markers[args.markerName]
    @$scope.editState.markerSelected = marker
    @$scope.editState.markerPropertiesBB =
      top: args.leafletEvent.originalEvent.clientY - 7
      bottom: args.leafletEvent.originalEvent.clientY - 7
      left: args.leafletEvent.originalEvent.clientX - 7
      width: 0


  disableMarkerSelectedState: ->
    @$scope.editState.markerSelected = false


  disableAddMarkerState: ->
    @$scope.editState.addMarker = false


  addMarker: (event) ->
    # NOTE: since the snippet data is a reference to the scope var, we
    # can work with the collection directly. For once the non-deep-copy thing
    # comes in handy :)
    newMarker =
      lat: @$scope.editState.geolocation.lat
      lng: @$scope.editState.geolocation.lng
      uuid: livingmapsUid.guid()
    @$scope.markers.push(newMarker)

    @disableAddMarkerState()
    @$scope.editState.markerSelected = newMarker
    @$scope.editState.markerPropertiesBB =
      top: event.clientY - 7
      bottom: event.clientY - 7
      left: event.clientX - 7
      width: 0


  removeMarker: (marker) ->
    idx = @$scope.markers.indexOf(marker)
    @$scope.markers.splice(idx, 1)
    @$scope.editState.markerSelected = false


  close: (event) ->
    @snippet.data
      center:
        lat: @$scope.center.lat
        lng: @$scope.center.lng
        zoom: @$scope.center.zoom
    @$modalInstance.dismiss('close')
    event.stopPropagation() # so sidebar selection is not lost
