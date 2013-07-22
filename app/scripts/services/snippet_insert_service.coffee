angular.module('ldEditor').factory('snippetInsertService', [
  'uiStateService'
  '$compile'
  'docObserverService'
  (uiStateService, $compile, docObserverService) ->


    page = new SnippetInsertor
      uiStateService: uiStateService
      $compile: $compile
      docObserverService: docObserverService

    page
])
