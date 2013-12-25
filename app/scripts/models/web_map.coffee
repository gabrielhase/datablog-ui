class WebMap

  constructor: (@id) ->
    @mapMediatorService = angularHelpers.inject('mapMediatorService')


  getTemplate: ->
    webMapConfig.template
