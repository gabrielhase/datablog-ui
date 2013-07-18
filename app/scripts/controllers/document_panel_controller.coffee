class DocumentPanelController


  constructor: ($scope, currentDocumentService) ->
    $scope.document = currentDocumentService.get()


angular.module('ldEditor').controller(
  'DocumentPanelController'
  [
    '$scope'
    'currentDocumentService'
    DocumentPanelController
  ]
)