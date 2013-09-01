angular.module('ldEditor').controller 'PropertiesPanelController',
class PropertiesPanelController

  constructor: (@$scope, @mapInsertService) ->
    @$scope.deleteSnippet = (snippet) => @deleteSnippet(snippet)
    @$scope.isDeletable = (snippet) => @isDeletable(snippet)


  deleteSnippet: (snippet) ->
    @mapInsertService.removeMap(snippet.model) if @mapInsertService.isMapSnippet(snippet.model)
    snippet.model.remove()


  isDeletable: (snippet) ->
    snippet && !@isRootContainer(snippet)


  isRootContainer: (snippet) ->
    snippet.model.parentContainer.isRoot
