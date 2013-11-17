angular.module('ldEditor').controller 'HistoryModalController',
class HistoryModalController

  constructor: (@$scope, @$modalInstance, @snippet, @documentService, @$timeout,
    @editorService, @uiStateService, @angularTemplateService, @mapMediatorService) ->
    @$scope.close = (event) => @close(event)
    @$scope.snippet = @snippet
    @documentService.getHistory(@editorService.getCurrentDocument().id, @snippet.id).then (history) =>
      @$scope.history = history

    # temporarily disable autosave
    @uiStateService.set('autosave', false)


    @$timeout => # we need a timeout to make sure the modal html template is ready
      @setupLatestVersion()


  setupLatestVersion: ->
    $previewRoot = $('.upfront-snippet-history .latest-preview')
    @latestVersionSnippet = @snippet.copy(doc.document.design)
    @angularTemplateService.insertTemplateInstance @latestVersionSnippet, $previewRoot, new ChoroplethMap
      id: @latestVersionSnippet.id
      mapMediatorService: @mapMediatorService


  removeLatestVersionInstance: ->
    @angularTemplateService.removeAngularTemplate(@latestVersionSnippet)
    delete @latestVersionSnippet


  close: (event) ->
    # TODO: put the changed data from @latestVersionSnippet to @snippet and save

    @removeLatestVersionInstance()
    # re-enable autosave
    @uiStateService.set('autosave', {})
    @$modalInstance.dismiss('close')
    event.stopPropagation() # so sidebar selection is not lost
