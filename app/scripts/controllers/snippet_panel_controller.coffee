class SnippetPanelController

  angular.module('ldEditor').controller 'SnippetPanelController',
  [ '$scope', 'docObserverService', 'snippetInsertService', SnippetPanelController ]

  constructor: ($scope, docObserverService, snippetInsertService) ->
    $scope.snippetInsertService = snippetInsertService
    $scope.snippets = @initSnippets()
    $scope.selectSnippet = ($event, $index, snippet) => @selectSnippet($scope, $event, $index, snippet, docObserverService)


  initSnippets: () ->
    design = doc.getDesign()
    for name, template of design.templates
      template


  selectSnippet: ($scope, $event, $index, snippet, docObserverService) ->
    $scope.snippetInsertService.selectedSnippet = $index # work with index in order not to have deep comparison
    docObserverService.snippetTemplateClick.fire($event, snippet)
