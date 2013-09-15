angular.module('ldEditor').factory 'snippetInsertService',
  (uiStateService, $compile, editorService, livingdocsService, mapInsertService) ->

    page = new SnippetInsertor
      uiStateService: uiStateService
      $compile: $compile
      mapInsertService: mapInsertService
      editorService: editorService
      livingdocsService: livingdocsService

    page
