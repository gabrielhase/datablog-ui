angular.module('ldEditor').factory('snippetInsertService', [
  'uiStateService'
  '$compile'
  'docObserverService'
  (uiStateService, $compile, docObserverService) ->


    page = new models.SnippetInsertor
      uiStateService: uiStateService
      $compile: $compile
      docObserverService: docObserverService

    page
])