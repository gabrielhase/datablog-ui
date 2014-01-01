angular.module('ldEditor').controller 'DocumentPanelController',
class DocumentPanelController

  constructor: ($scope, @editorService, @documentService) ->
    $scope.document = @editorService.currentDocument
    $scope.resetStory = $.proxy(@resetStory, this)


  resetStory: ->
    doc.stash.clear()
    window.location = '/' # NOTE: reload the browser for now, reloading a document is not supported yet.

