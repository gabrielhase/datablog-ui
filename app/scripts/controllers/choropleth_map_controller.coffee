angular.module('ldEditor').controller 'ChoroplethMapController',
class ChoroplethMapController

  constructor: (@$scope, @ngProgress, @mapMediatorService, @$timeout) ->
    @choroplethMapInstance = @mapMediatorService.getUIModel(@$scope.mapId)
    @snippetModel = @mapMediatorService.getSnippetModel(@$scope.mapId)

    @snippetModel.data
      lastPositioned: (new Date()).getTime()

    @setupSnippetChangeListener()
    @$timeout => # the timeout makes sure that the choropleth property listeners are already setup
      @initScope()


  initScope: ->
    for trackedProperty in choroplethMapConfig.trackedProperties
      propertyValue = @snippetModel.data(trackedProperty)
      if propertyValue
        @$scope[trackedProperty] = propertyValue
      else if choroplethMapConfig.kickstartProperties[trackedProperty]
        @$scope[trackedProperty] = choroplethMapConfig.kickstartProperties[trackedProperty]


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

