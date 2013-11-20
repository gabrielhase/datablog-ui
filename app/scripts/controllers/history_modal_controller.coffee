angular.module('ldEditor').controller 'HistoryModalController',
class HistoryModalController

  constructor: (@$scope, @$modalInstance, @$timeout, @snippet, @documentService,
    @editorService, @uiStateService, @angularTemplateService, @mapMediatorService) ->
    @$scope.close = (event) => @close(event)
    @$scope.snippet = @snippet
    @documentService.getHistory(@editorService.getCurrentDocument().id, @snippet.id).then (history) =>
      @$scope.history = history
      if history.length > 0
        @$modalInstance.opened.then =>
          @$timeout =>
            @addHistoryVersion(history[0])

    # NOTE: Agnular-ui-boostraps modal needs a timeout to be sure that the content of
    # the modal is rendered. This is pretty ugly, so we probalby should move away from
    # angular-ui-bootstrap...
    # http://stackoverflow.com/questions/14833326/how-to-set-focus-in-angularjs
    @$modalInstance.opened.then =>
      @$timeout =>
        @setupLatestVersion()


  addHistoryVersion: (historyRevision) ->
    @documentService.getRevision(@editorService.getCurrentDocument().id, historyRevision.revisionId).then (documentRevision) =>
      $previewRoot = $('.upfront-snippet-history .history-explorer')
      if documentRevision.data.content
        for snippetJson in documentRevision.data.content
          @searchHistorySnippet(snippetJson)

      log.error 'The history document has to contain the map' unless @historyVersionSnippet

      @angularTemplateService.insertTemplateInstance @historyVersionSnippet, $previewRoot, new ChoroplethMap
        id: @historyVersionSnippet.id
        mapMediatorService: @mapMediatorService


  # takes array of snippets or containers and looks for the snippet in the snippet tree
  # that has the same id.
  # Assigns this snippet to @historyVersionSnippet
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
