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
        @populateData()


  populateData: (snippetModel, scope) ->
    for trackedProperty in ['map', 'data', 'lastPositioned', 'projection']
      newVal = @choroplethMapInstance.processValue(trackedProperty, @snippetModel.data(trackedProperty))
      if newVal
        if @ngProgress.status() == 0 && @choroplethMapInstance.shouldRenderLoadingBar(@snippetModel)
          @ngProgress.start()
          @ngProgress.set(10)
        @$scope[trackedProperty] = newVal