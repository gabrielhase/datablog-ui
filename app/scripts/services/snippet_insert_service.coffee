angular.module('ldEditor').factory 'snippetInsertService',
  (uiStateService, $compile, editorService, docService) ->

    page = new SnippetInsertor
      uiStateService: uiStateService
      $compile: $compile
      editorService: editorService
      docService: docService

    page
