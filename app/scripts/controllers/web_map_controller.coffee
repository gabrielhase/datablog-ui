angular.module('ldEditor').controller 'WebMapController',
class WebMapController

  constructor: (@$scope, @mapMediatorService, @leafletData, @$timeout) ->
    @snippetModel = @mapMediatorService.getSnippetModel(@$scope.mapId)
    @uiModel = @mapMediatorService.getUIModel(@$scope.mapId)
    @snippetModel.data
      lastPositioned: (new Date()).getTime()

    @initMarkers()
    @setupSnippetChangeListener()
    @initScope()
    @initEditingDefaults()
    # NOTE: if maps are added with JQuery or css properties change then
    # invalidateSize() must be called to make sure the tiles are rendered
    # correctly. This automatically does this upon loading a map.
    @$timeout =>
      @reloadMap()
    , 10


  initMarkers: ->
    if @snippetModel.data('markers')
      for marker in @snippetModel.data('markers')
        if marker.icon && marker.icon.options
          marker.icon = new L.AwesomeMarkers.icon
            icon: marker.icon.options.icon
            prefix: marker.icon.options.prefix
            markerColor: marker.icon.options.markerColor


  reloadMap: ->
    @uiModel.reload(@$scope.mapId)


  initScope: ->
    @initDefaults()
    for property in ['center', 'markers', 'tiles']
      @$scope[property] = @$scope.snippetModel.data(property)


  initDefaults: ->
    @$scope.snippetModel = @mapMediatorService.getSnippetModel(@$scope.mapId)
    # tile layer: openstreetmap
    unless @$scope.snippetModel.data('tiles')
      @$scope.snippetModel.data
        tiles: @uiModel.getAvailableTileLayers()['openstreetmap']
    # center: Zurich
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
            icon: @uiModel.getDefaultIcon()
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
    @reloadMap() if changedProperties.indexOf('lastPositioned') != -1
    for trackedProperty in webMapConfig.trackedProperties
      if changedProperties.indexOf(trackedProperty) != -1
        newVal = @snippetModel.data(trackedProperty)
        if typeof(newVal) != 'undefined'
          @$scope[trackedProperty] = newVal
