angular.module('ldEditor').controller 'DocumentPanelController',
class DocumentPanelController

  constructor: ($scope, @editorService, @documentService) ->
    $scope.document = @editorService.currentDocument
    $scope.resetStory = $.proxy(@resetStory, this)


  resetStory: ->
    doc.stash.clear()
    window.location = '/'
    # @documentService.get(15).then (document) =>
    #   @editorService.loadDocument(document)

