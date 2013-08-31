angular.module('ldEditor').controller 'SnippetPanelController',
class SnippetPanelController

  constructor: ($scope, @editorService, snippetInsertService) ->
    $scope.snippetInsertService = snippetInsertService
    $scope.groups = @initGroups()
    $scope.snippets = @initSnippets()
    $scope.selectSnippet = ($event, $index, snippet) => @selectSnippet($scope, $event, $index, snippet)


  initSnippets: () ->
    design = doc.getDesign()
    for name, template of design.templates
      template

  initGroups: () ->
    design = doc.getDesign()
    for name, group of design.groups
      group


  selectSnippet: ($scope, $event, $index, snippet) ->
    $scope.snippetInsertService.selectedSnippet = $index # work with index in order not to have deep comparison
    @editorService.snippetTemplateClick.fire($event, snippet)
