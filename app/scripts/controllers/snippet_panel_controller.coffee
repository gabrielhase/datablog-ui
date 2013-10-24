angular.module('ldEditor').controller 'SnippetPanelController',
class SnippetPanelController

  constructor: (@$scope, @editorService, snippetInsertService) ->
    @$scope.snippetInsertService = snippetInsertService
    @$scope.groups = @initGroups()
    @$scope.snippets = @initSnippets()
    @$scope.selectSnippet = ($event, groupId, $index, snippet) => @selectSnippet($event, groupId, $index, snippet)


  initSnippets: () ->
    design = doc.getDesign()
    for name, template of design.templates
      template


  initGroups: () ->
    design = doc.getDesign()
    for name, group of design.groups
      group.id = name
      group


  selectSnippet: ($event, groupId, $index, snippet) ->
    @$scope.snippetInsertService.selectedSnippet = "#{groupId}.#{$index}" # work with index in order not to have deep comparison
    @editorService.snippetTemplateClick.fire($event, snippet)
