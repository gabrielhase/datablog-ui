angular.module('ldEditor').controller 'MapKickstartModalController',
class MapKickstartModalController

  constructor: (@$scope, @$modalInstance, @data, @leafletData, @$timeout) ->
    @$scope.close = $.proxy(@close, this)
    @initMarkers()
    @initMap() if @$scope.markers.length > 0
    @setupGlobalTextProperty()


  initMap: ->
    @$scope.center =
      zoom: 8
      lat: @$scope.markers[0].geojson.geometry.coordinates[1]
      lng: @$scope.markers[0].geojson.geometry.coordinates[0]
    @$scope.previewMarkers = _.map @$scope.markers, (marker) ->
      lat: marker.geojson.geometry.coordinates[1]
      lng: marker.geojson.geometry.coordinates[0]
    @$timeout => # we need a timeout here to wait for the directive to be done
      @leafletData.getMap().then (map) =>
        map.fitBounds(@getBounds(@$scope.previewMarkers))
    , 100


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


  setupGlobalTextProperty: ->
    @$scope.globalValues = {}
    @$scope.globalValues.textProperty = ''
    @$scope.$watch('globalValues.textProperty', (newVal, oldVal) =>
      for marker in @$scope.markers
        marker.selectedTextProperty = newVal
    )


  initMarkers: ->
    @$scope.markers = []
    @$scope.globalTextProperties = []
    for feature in @data.features
      if feature.type == 'Feature' && feature.geometry?.type == 'Point'
        @$scope.markers.push
          selected: true
          geojson: feature
          textProperties: @getTextProperties(feature)
        if @$scope.globalTextProperties.length == 0
          @$scope.globalTextProperties = @getTextProperties(feature)
        else
          featureTextProperties = @getTextProperties(feature)
          for property, idx in @$scope.globalTextProperties
            if featureTextProperties.indexOf(property) == -1
              @$scope.globalTextProperties.splice(idx, 1)


  getTextProperties: (feature) ->
    _.keys(feature.properties)


  close: (event) ->
    @$modalInstance.dismiss('close')
    event.stopPropagation() # so sidebar selection is not lost



