angular.module('ldEditor').controller 'MapEditModalController',
class MapEditModalController

  constructor: (@$scope, @$modalInstance, @snippet, @uiModel, @leafletData, @$timeout, @leafletEvents) ->
    @$scope.close = $.proxy(@close, this)
    @$scope.addMarker = $.proxy(@addMarker, this)
    @$scope.removeMarker = $.proxy(@removeMarker, this)
    @$scope.disableMarkerSelectedState = $.proxy(@disableMarkerSelectedState, this)
    @$scope.selectIcon = $.proxy(@selectIcon, this)
    @$scope.center = @snippet.data('center')
    @$scope.markers = @snippet.data('markers')
    @$scope.tiles = @snippet.data('tiles')
    @$scope.editState = {}
    @$scope.uiModel = @uiModel

    @addGeosearch()
    @setupMapEvents()
    @enableDraggableForMarker()


  addGeosearch: ->
    @$timeout =>
      @leafletData.getMap("freeform-map").then (map) =>
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


  selectIcon: (marker, icon) ->
    marker.icon = L.AwesomeMarkers.icon
      icon: icon
      markerColor: marker.icon.options.markerColor
      prefix: marker.icon.options.prefix


  addMarker: (event) ->
    # NOTE: since the snippet data is a reference to the scope var, we
    # can work with the collection directly. For once the non-deep-copy thing
    # comes in handy :)
    newMarker =
      lat: @$scope.editState.geolocation.lat
      lng: @$scope.editState.geolocation.lng
      uuid: livingmapsUid.guid()
      icon: @uiModel.getDefaultIcon()
      draggable: true
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


  enableDraggableForMarker: ->
    for marker in @$scope.markers
      marker.draggable = true


  disableDraggableForMarkers: ->
    for marker in @$scope.markers
      marker.draggable = false


  close: (event) ->
    @snippet.data
      center:
        lat: @$scope.center.lat
        lng: @$scope.center.lng
        zoom: @$scope.center.zoom
    @disableDraggableForMarkers()
    @$modalInstance.dismiss('close')
    event.stopPropagation() # so sidebar selection is not lost
