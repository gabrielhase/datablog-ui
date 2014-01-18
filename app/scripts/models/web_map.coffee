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
