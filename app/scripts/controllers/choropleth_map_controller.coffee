angular.module('ldEditor').controller 'ChoroplethMapController',
class ChoroplethMapController

  constructor: (@$scope, @ngProgress) ->
    @choroplethMapInstance = @$scope.templateInstance
    @snippetModel = @$scope.snippetModel

    @snippetModel.data
      lastPositioned: (new Date()).getTime()

    @setupSnippetChangeListener()


  setupSnippetChangeListener: ->
    doc.snippetDataChanged (snippet, changedProperties) =>
      if snippet.id == @snippetModel.id
        @changeChoroplethAttrsData(changedProperties)


  changeChoroplethAttrsData: (changedProperties) ->
    for trackedProperty in choroplethMapConfig.trackedProperties
      if changedProperties.indexOf(trackedProperty) != -1
        newVal = @snippetModel.data(trackedProperty)
        if newVal
          if @ngProgress.status() == 0 && @choroplethMapInstance.shouldRenderLoadingBar(@snippetModel, trackedProperty)
            @ngProgress.start()
            @ngProgress.set(10)
          @$scope[trackedProperty] = newVal

