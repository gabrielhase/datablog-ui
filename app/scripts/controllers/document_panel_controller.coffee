angular.module('ldEditor').controller 'DocumentPanelController',
class DocumentPanelController

  constructor: ($scope, editorService) ->
    $scope.document = editorService.currentDocument
