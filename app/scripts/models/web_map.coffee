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
