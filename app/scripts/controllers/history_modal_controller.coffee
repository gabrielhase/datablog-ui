angular.module('ldEditor').controller 'HistoryModalController',
class HistoryModalController

  constructor: (@$scope, @$modalInstance, @snippet, @documentService, @$timeout,
    @editorService, @uiStateService, @angularTemplateService, @mapMediatorService) ->
    @$scope.close = (event) => @close(event)
    @$scope.snippet = @snippet
    @documentService.getHistory(@editorService.getCurrentDocument().id, @snippet.id).then (history) =>
      @$scope.history = history
      if history.length > 0
        @$timeout =>
          @addHistoryVersion(history[history.length - 1])


    @$timeout => # we need a timeout to make sure the modal html template is ready
      @setupLatestVersion()


  addHistoryVersion: (historyDocument) ->
    $previewRoot = $('.upfront-snippet-history .history-explorer')
    if historyDocument.data.content
      for snippetJson in historyDocument.data.content
        @searchHistorySnippet(snippetJson)

    log.error 'The history document has to contain the map' unless @historyVersionSnippet

    @angularTemplateService.insertTemplateInstance @historyVersionSnippet, $previewRoot, new ChoroplethMap
      id: @historyVersionSnippet.id
      mapMediatorService: @mapMediatorService


  # takes array of snippets or containers
  searchHistorySnippet: (snippetJson) ->
    if snippetJson.hasOwnProperty('containers')
      for container of snippetJson.containers
        containerJson = snippetJson.containers[container]
        for childSnippetJson in containerJson
          @searchHistorySnippet(childSnippetJson)
    else
      if snippetJson.id == @snippet.id
        # NOTE: here we change the id in order not to conflict with the version on the page
        snippetJson.id = "#{snippetJson.id}-101"
        # TODO: make a bit of a safer key function
        @historyVersionSnippet = doc.snippetFromJson(snippetJson, doc.document.design)


  removeHistoryVersionInstance: ->
    @angularTemplateService.removeAngularTemplate(@historyVersionSnippet)
    delete @historyVersionSnippet


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
    @removeHistoryVersionInstance()
    @$modalInstance.dismiss('close')
    event.stopPropagation() # so sidebar selection is not lost
