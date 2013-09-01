angular.module('ldEditor').factory 'snippetInsertService',
  (uiStateService, $compile, editorService, docService, mapInsertService) ->

    page = new SnippetInsertor
      uiStateService: uiStateService
      $compile: $compile
      mapInsertService: mapInsertService
      editorService: editorService
      docService: docService

    page
