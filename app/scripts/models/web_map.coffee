class WebMap

  constructor: (@id) ->
    @mapMediatorService = angularHelpers.inject('mapMediatorService')


  getTemplate: ->
    webMapConfig.template


  getDefaultIcon: ->
    L.AwesomeMarkers.icon
      icon: 'star'
      markerColor: 'cadetblue'
      prefix: 'fa'


  getAvailableIcons: ->
    [
      # abstract
      'star',
      'gear',
      'bookmark',
      'circle',
      'rocket',
      'info',
      # concrete
      'coffee',
      'stethoscope',
      'wheelchair',
      'glass',
      'cutlery',
      'shopping-cart',
      'road'
    ]


  getAvailableTileLayers: ->
    openstreetmap:
      name: 'openstreetmap'
      url: "http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
      options:
        attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    opencyclemap:
      name: 'opencyclemap'
      url: "http://{s}.tile.opencyclemap.org/cycle/{z}/{x}/{y}.png"
      options:
        attribution: 'All maps &copy; <a href="http://www.opencyclemap.org">OpenCycleMap</a>, map data &copy; <a href="http://www.openstreetmap.org">OpenStreetMap</a> (<a href="http://www.openstreetmap.org/copyright">ODbL</a>'
    mapquestaerial:
      name: 'mapquestaerial'
      url: "http://otile{s}.mqcdn.com/tiles/1.0.0/{type}/{z}/{x}/{y}.png"
      options:
        subdomains: '1234'
        type: 'sat'
        attribution: 'Imagery &copy; NASA/JPL-Caltech and U.S. Depart. of Agriculture, Farm Service Agency, Tiles &copy; <a href="http://www.mapquest.com/" target="_blank">MapQuest</a> <img src="http://developer.mapquest.com/content/osm/mq_logo.png" />'
    arcgis:
      name: 'arcgis'
      url: "http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}"
    mapbox:
      name: 'mapbox'
      url: "http://{s}.tiles.mapbox.com/v3/{user}.{map}/{z}/{x}/{y}.png"
      options:
        user: 'gabriel-hase'
        map: 'h1kmko7c'


  _getSnippetModel: ->
    @mapMediatorService.getSnippetModel(@id)


  # ########################
  # DIFFERENCE CALCULATIONS
  # ########################

  # Tile Layer
  # Center
  # Zoom
  # Markers
  calculateDifference: (otherVersion) ->
    versionDifferences = []
    versionDifferences.push
      secionTitle: 'Map Properties'
      properties: []
    versionDifferences[0].properties.push(@_calculateTileLayerDifference(otherVersion))
    versionDifferences.push
      secionTitle: 'View Box'
      properties: []
    versionDifferences[1].properties.push(@_calculateCenterDifference(otherVersion))

    versionDifferences


  _calculateTileLayerDifference: (otherVersion) ->
    currentTileLayer = @_getSnippetModel().data('tiles')
    otherTileLayer = otherVersion.data('tiles')
    tileLayerDiffEntry =
      label: 'Tile Layer'
      key: 'tiles'
    tileLayerDiffEntry.difference = @_getDifferenceType(currentTileLayer.name, otherTileLayer.name)
    unless tileLayerDiffEntry.difference
      tileLayerDiffEntry.info = "(#{currentTileLayer.name})"
    tileLayerDiffEntry


  _calculateCenterDifference: (otherVersion) ->
    currentCenter = @_getSnippetModel().data('center')
    otherCenter = otherVersion.data('center')
    centerDiffEntry =
      label: 'Center'
      key: 'center'
    if !@_deepEquals(currentCenter, otherCenter)
      centerDiffEntry.difference = 'blobChange'

    centerDiffEntry


  _getDifferenceType: (currentValue, otherValue) ->
    if !currentValue
      type: 'delete'
      content: otherValue
    else if !otherValue
      type: 'add'
      content: currentValue
    else
      if currentValue != otherValue
        type: 'change'
        previous: otherValue
        after: currentValue
      else
        undefined


  # very primitive implementation that does NOT work when contents come
  # in a different order, e.g. {a: 1, b: 2} != {b: 2, a: 1}
  # a better solution is here: http://stackoverflow.com/questions/1068834/object-comparison-in-javascript
  _deepEquals: (o1, o2) ->
    JSON.stringify(o1) == JSON.stringify(o2)

