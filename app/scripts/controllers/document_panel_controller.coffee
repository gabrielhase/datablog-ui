class DocumentPanelController

  angular.module('ldEditor').controller 'DocumentPanelController',
    ['$scope', 'documentService', DocumentPanelController ]

  constructor: ($scope, documentService) ->
    $scope.document = documentService.get()
