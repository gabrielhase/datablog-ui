class DocumentPanelController


  constructor: ($scope, documentService) ->
    $scope.document = documentService.get()


angular.module('ldEditor').controller(
  'DocumentPanelController'
  [
    '$scope'
    'documentService'
    DocumentPanelController
  ]
)
