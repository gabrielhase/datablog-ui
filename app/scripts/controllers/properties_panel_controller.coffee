angular.module('ldEditor').controller 'PropertiesPanelController',
class PropertiesPanelController

  constructor: (@$scope) ->
    @$scope.deleteSnippet = (snippet) => @deleteSnippet(snippet)
    @$scope.isDeletable = (snippet) => @isDeletable(snippet)


  deleteSnippet: (snippet) ->
    snippet.model.remove()


  isDeletable: (snippet) ->
    snippet && !@isRootContainer(snippet)


  isRootContainer: (snippet) ->
    snippet.model.parentContainer.isRoot
