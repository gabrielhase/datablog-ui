angular.module('ldEditor').controller 'PropertiesPanelController',
class PropertiesPanelController

  constructor: (@$scope, @angularTemplateService, @uiStateService) ->
    @$scope.deleteSnippet = $.proxy(@deleteSnippet, this)
    @$scope.isDeletable = $.proxy(@isDeletable, this)


  deleteSnippet: (snippet) ->
    @uiStateService.blurCurrentSnippet()
    @angularTemplateService.removeAngularTemplate(snippet.model) if @angularTemplateService.isAngularTemplate(snippet.model)
    snippet.model.remove()


  isDeletable: (snippet) ->
    snippet && !@isRootContainer(snippet)


  isRootContainer: (snippet) ->
    snippet.model.parentContainer.isRoot
