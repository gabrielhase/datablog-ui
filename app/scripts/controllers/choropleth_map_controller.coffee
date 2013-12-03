angular.module('ldEditor').controller 'ChoroplethMapController',
class ChoroplethMapController

  constructor: (@$scope, @ngProgress, @mapMediatorService, @$timeout) ->
    @colorSchemeCallback = $.Callbacks('memory')

    @choroplethMapInstance = @mapMediatorService.getUIModel(@$scope.mapId)
    @snippetModel = @mapMediatorService.getSnippetModel(@$scope.mapId)

    @snippetModel.data
      lastPositioned: (new Date()).getTime()

    @setupKickstarters()
    @setupSnippetChangeListener()
    @$timeout => # the timeout makes sure that the choropleth property listeners are already setup
      @initScope()


  setupKickstarters: ->
    for property, propertyValue of choroplethMapConfig.kickstartProperties
      unless @snippetModel.data(property)
        kickstartProperty = {}
        kickstartProperty["#{property}"] = propertyValue
        @snippetModel.data(kickstartProperty)
    @initColorSchemeCallback()


  initColorSchemeCallback: ->
    @colorSchemeCallback.add =>
      if @choroplethMapInstance.getValueType() == 'numerical'
        @snippetModel.data
          colorScheme: 'YlGn'
      else
        @snippetModel.data
          colorScheme: 'Paired'


  initScope: ->
    for trackedProperty in choroplethMapConfig.trackedProperties
      propertyValue = @snippetModel.data(trackedProperty)
      if propertyValue
        @$scope[trackedProperty] = propertyValue
        @handleKickstartCallbacks(trackedProperty)


  setupSnippetChangeListener: ->
    doc.snippetDataChanged (snippet, changedProperties) =>
      if snippet.id == @snippetModel.id
        @changeChoroplethAttrsData(changedProperties)


  changeChoroplethAttrsData: (changedProperties) ->
    for trackedProperty in choroplethMapConfig.trackedProperties
      if changedProperties.indexOf(trackedProperty) != -1
        newVal = @snippetModel.data(trackedProperty)
        if newVal
          if @ngProgress.status() == 0 && @choroplethMapInstance.shouldRenderLoadingBar(trackedProperty)
            @ngProgress.start()
            @ngProgress.set(10)
          @$scope[trackedProperty] = newVal
          @handleKickstartCallbacks(trackedProperty)


  handleKickstartCallbacks: (changedProperty) ->
    if changedProperty == 'data'
      @colorSchemeCallback.fire()
    # once the user has set the color scheme manually the callbacks should never trigger
    @colorSchemeCallback.disable() if changedProperty == 'colorScheme'


