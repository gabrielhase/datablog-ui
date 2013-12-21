angular.module('ldEditor').controller 'MapKickstartModalController',
class MapKickstartModalController

  constructor: (@$scope, @$modalInstance, @data) ->
    @$scope.close = $.proxy(@close, this)
    @initMarkers()

    @setupGlobalTextProperty()


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



