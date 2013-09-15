angular.module('ldEditor').controller 'PropertiesPanelController',
class PropertiesPanelController

  constructor: (@$scope, @angularTemplateService) ->
    @$scope.deleteSnippet = (snippet) => @deleteSnippet(snippet)
    @$scope.isDeletable = (snippet) => @isDeletable(snippet)


  deleteSnippet: (snippet) ->
    @angularTemplateService.removeAngularTemplate(snippet.model) if @angularTemplateService.isAngularTemplate(snippet.model)
    snippet.model.remove()


  isDeletable: (snippet) ->
    snippet && !@isRootContainer(snippet)


  isRootContainer: (snippet) ->
    snippet.model.parentContainer.isRoot
