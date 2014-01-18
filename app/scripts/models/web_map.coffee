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
