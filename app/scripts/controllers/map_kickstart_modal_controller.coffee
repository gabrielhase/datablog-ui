angular.module('ldEditor').controller 'MapKickstartModalController',
class MapKickstartModalController

  constructor: (@$scope, @$modalInstance, @data, @uiModel, @leafletData, @$timeout, @leafletEvents) ->
    @$scope.close = $.proxy(@close, this)
    @$scope.highlightMarker = $.proxy(@highlightMarker, this)
    @$scope.unHighlightMarker = $.proxy(@unHighlightMarker, this)
    @$scope.toggleMarker = $.proxy(@toggleMarker, this)
    @$scope.hasMarkers = $.proxy(@hasMarkers, this)
    @$scope.kickstart = $.proxy(@kickstart, this)

    @initMarkers()
    @initMarkerStyles()
    @initMap() if @$scope.markers.length > 0
    @setupMarkerEvents() if @$scope.markers.length > 0
    @setupGlobalProperties()


  initMarkers: ->
    @$scope.markers = []
    @$scope.globalTextProperties = []
    for feature in @data.features
      if feature.type == 'Feature' && feature.geometry?.type == 'Point'
        @$scope.markers.push
          selected: true
          uuid: livingmapsUid.guid()
          geojson: feature
          textProperties: @getTextProperties(feature)
        if @$scope.globalTextProperties.length == 0
          @$scope.globalTextProperties = @getTextProperties(feature)
        else
          featureTextProperties = @getTextProperties(feature)
          for property, idx in @$scope.globalTextProperties
            if featureTextProperties.indexOf(property) == -1
              @$scope.globalTextProperties.splice(idx, 1)


  highlightMarker: (index) ->
    if @$scope.previewMarkers[index].icon == @removedMarker
      @$scope.previewMarkers[index].icon = @addMarker
    else
      @$scope.previewMarkers[index].icon = @removeMarker


  unHighlightMarker: (index) ->
    if @$scope.markers[index].selected
      @$scope.previewMarkers[index].icon = @addedMarker
    else
      @$scope.previewMarkers[index].icon = @removedMarker


  toggleMarker: (marker, index) ->
    marker.selected = !marker.selected
    if marker.selected
      @$scope.previewMarkers[index].icon = @addedMarker
    else
      @$scope.previewMarkers[index].icon = @removedMarker


  initMarkerStyles: ->
    @addedMarker = L.AwesomeMarkers.icon
      icon: 'fa-check'
      markerColor: 'darkgreen'
      prefix: 'fa'
    @addMarker = L.AwesomeMarkers.icon
      icon: 'fa-plus'
      markerColor: 'green'
      prefix: 'fa'
    @removeMarker = L.AwesomeMarkers.icon
      icon: 'fa-minus'
      markerColor: 'red'
      prefix: 'fa'
    @removedMarker = L.AwesomeMarkers.icon
      icon: 'fa-times'
      markerColor: 'cadetblue'
      prefix: 'fa'


  initMap: ->
    @$scope.center =
      zoom: 8
      lat: @$scope.markers[0].geojson.geometry.coordinates[1]
      lng: @$scope.markers[0].geojson.geometry.coordinates[0]
    @$scope.previewMarkers = _.map @$scope.markers, (marker) =>
      lat: marker.geojson.geometry.coordinates[1]
      lng: marker.geojson.geometry.coordinates[0]
      riseOnHover: true
      icon: @addedMarker
    @$timeout => # we need a timeout here to wait for the directive to be done
      @leafletData.getMap().then (map) =>
        map.fitBounds(@getBounds(@$scope.previewMarkers))
    , 100


  setupMarkerEvents: ->
    @$scope.events =
      markers:
        enable: @leafletEvents.getAvailableMarkerEvents()

    @$scope.$on 'leafletDirectiveMarker.click', (e, args) =>
      # NOTE: The markerName is the index
      @toggleMarker(@$scope.markers[+args.markerName], +args.markerName)
      # TODO: maybe scroll to entry

  setupGlobalProperties: ->
    @$scope.globalValues = {}
    @$scope.globalValues.textProperty = ''
    @$scope.globalValues.selected = true
    @$scope.$watch('globalValues.textProperty', (newVal, oldVal) =>
      for marker in @$scope.markers
        marker.selectedTextProperty = newVal
    )
    @$scope.$watch('globalValues.selected', (newVal, oldVal) =>
      for marker, idx in @$scope.markers
        if marker.selected != newVal
          @toggleMarker(marker, idx)
    )



  # ########################
  # Modal Actions
  # ########################

  kickstart: (event) ->
    selectedMarkers = _.filter @$scope.markers, (marker) -> marker.selected
    @$modalInstance.close
      action: 'kickstart'
      markers: _.map selectedMarkers, (marker) =>
        lat: marker.geojson.geometry.coordinates[1]
        lng: marker.geojson.geometry.coordinates[0]
        message: marker.geojson.properties[marker.selectedTextProperty]
        uuid: marker.uuid
        icon: @uiModel.getDefaultIcon()
    event.stopPropagation() # so sidebar selection is not lost


  close: (event) ->
    @$modalInstance.dismiss('close')
    event.stopPropagation() # so sidebar selection is not lost


  # ########################
  # Utils
  # ########################

  hasMarkers: ->
    _.any @$scope.markers, (marker) -> marker.selected


  getBounds: (markers) ->
    maxLat = @getMinOrMax(markers, 'max', 'lat')
    maxLng = @getMinOrMax(markers, 'max', 'lng')
    minLat = @getMinOrMax(markers, 'min', 'lat')
    minLng = @getMinOrMax(markers, 'min', 'lng')
    southWest = new L.LatLng(minLat, minLng)
    northEast = new L.LatLng(maxLat, maxLng)
    new L.LatLngBounds(southWest, northEast)


  getMinOrMax: (markers, minOrMax, latOrLng) ->
    _[minOrMax](_.map markers, (marker) -> marker[latOrLng])


  getTextProperties: (feature) ->
    _.keys(feature.properties)
