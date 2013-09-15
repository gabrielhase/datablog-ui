angular.module('ldEditor').factory 'snippetInsertService',
  (uiStateService, $compile, editorService, livingdocsService, angularTemplateService) ->

    page = new SnippetInsertor
      uiStateService: uiStateService
      $compile: $compile
      angularTemplateService: angularTemplateService
      editorService: editorService
      livingdocsService: livingdocsService

    page
