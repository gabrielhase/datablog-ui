angular.module('ldEditor').controller 'WebMapController',
class WebMapController

  constructor: (@$scope, @mapMediatorService) ->
    @snippetModel = @mapMediatorService.getSnippetModel(@$scope.mapId)
    @snippetModel.data
      lastPositioned: (new Date()).getTime()

    @setupSnippetChangeListener()
    @initScope()
    @initEditingDefaults()


  initScope: ->
    @initDefaults()
    for property in ['center', 'markers']
      @$scope[property] = @$scope.snippetModel.data(property)


  initDefaults: ->
    @$scope.snippetModel = @mapMediatorService.getSnippetModel(@$scope.mapId)
    unless @$scope.snippetModel.data('center')
      @$scope.snippetModel.data
        center:
          lat: 47.388778
          lng: 8.541971
          zoom: 12
    # NOTE: we need to set a dummy pin at the north pole because otherwise
    # the angular directive wouldn't watch for changes (line 623)
    markers = @$scope.snippetModel.data('markers')
    if !markers || markers.length == 0
      @$scope.snippetModel.data
        markers: [
          {
            lat: 90
            lng: 0
            uuid: ''
          }
        ]


  initEditingDefaults: ->
    @$scope.defaults =
      scrollWheelZoom: false
      zoomControl: false
      doubleClickZoom: false
      dragging: false
      keyboard: false


  setupSnippetChangeListener: ->
    doc.snippetDataChanged (snippet, changedProperties) =>
      if snippet.id == @snippetModel.id
        @changeMapAttrsData(changedProperties)


  changeMapAttrsData: (changedProperties) ->
    for trackedProperty in webMapConfig.trackedProperties
      if changedProperties.indexOf(trackedProperty) != -1
        newVal = @snippetModel.data(trackedProperty)
        if typeof(newVal) != 'undefined'
          @$scope[trackedProperty] = newVal

  # setupGeojsonListeners: (scope)->
  # scope.$on "leafletDirectiveMap.geojsonClick", (ev, featureSelected, leafletEvent) ->
  #   console.log(featureSelected)
