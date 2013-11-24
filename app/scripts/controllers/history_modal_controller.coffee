angular.module('ldEditor').controller 'HistoryModalController',
class HistoryModalController

  constructor: (@$scope, @$modalInstance, @$timeout, @$q, @snippet, @documentService,
    @editorService, @uiStateService, @angularTemplateService, @mapMediatorService) ->
    @$scope.snippet = @snippet
    @$scope.close = (event) => @close(event)
    @$scope.chooseRevision = (historyRevision) => @chooseRevision(historyRevision)
    @$scope.isSelected = (historyRevision) => @isSelected(historyRevision)
    @$scope.revertChange = (property) => @revertChange(property)

    @modelInstance = @mapMediatorService.getUIModel(@snippet.id)
    # NOTE: Agnular-ui-boostraps modal needs a timeout to be sure that the content of
    # the modal is rendered. This is pretty ugly, so we probalby should move away from
    # angular-ui-bootstrap...
    # http://stackoverflow.com/questions/14833326/how-to-set-focus-in-angularjs
    @$modalInstance.opened.then =>
      @$timeout =>
        @setupModalContent()


  setupModalContent: ->
    @setupLatestVersion()
    @documentService.getHistory(@editorService.getCurrentDocument().id, @snippet.id).then (history) =>
      @$scope.history = history
      if history.length > 0
        @setupHistoryPopovers()
        @addHistoryVersion(history[0]).then (historyVersion) =>
          @$scope.versionDifference = @modelInstance.calculateDifference(historyVersion)


  setupLatestVersion: ->
    $previewRoot = $('.upfront-snippet-history .latest-preview .latest-version-map')
    @latestVersionSnippet = @snippet.copy(doc.document.design)
    @angularTemplateService.insertTemplateInstance @latestVersionSnippet, $previewRoot, new ChoroplethMap
      id: @latestVersionSnippet.id
      mapMediatorService: @mapMediatorService


  removeLatestVersionInstance: ->
    @angularTemplateService.removeAngularTemplate(@latestVersionSnippet)
    delete @latestVersionSnippet


  close: (event) ->
    # TODO: put the changed data from @latestVersionSnippet to @snippet and save
    @removeLatestVersionInstance() if @latestVersionSnippet
    @removeHistoryVersionInstance() if @historyVersionSnippet
    @$modalInstance.dismiss('close')
    event.stopPropagation() # so sidebar selection is not lost


  # #########################
  # HISTORY VIEW
  # #########################

  isSelected: (historyRevision) ->
    historyRevision == @selectedHistoryRevision


  # As long as we don't need complicated content this is just a hacked Twitter
  # Bootstrap popover
  setupHistoryPopovers: ->
    $('.history-explorer').on 'mouseover', '.upfront-timeline-entry', (event) ->
      $el = $(event.currentTarget)
      date = moment($el.data('timestamp'), 'YYYY-MM-DD hh:mm:ss')
      $el.tooltip(
        html: true
        title: "<h5>Version #{$el.data('version')}</h5><p>#{date.fromNow()}</p>"
        placement: 'bottom'
      ).tooltip('show')


  chooseRevision: (historyRevision) ->
    @removeHistoryVersionInstance()
    @addHistoryVersion(historyRevision).then (historyVersion) =>
      @$scope.versionDifference = @modelInstance.calculateDifference(historyVersion)


  addHistoryVersion: (historyRevision) ->
    historyReady = @$q.defer()
    @selectedHistoryRevision = historyRevision
    @documentService.getRevision(@editorService.getCurrentDocument().id, historyRevision.revisionId).then (documentRevision) =>
      $previewRoot = $('.upfront-snippet-history .history-explorer .current-history-map')
      if documentRevision.data.content
        for snippetJson in documentRevision.data.content
          @searchHistorySnippet(snippetJson)

      log.error 'The history document has to contain the map' unless @historyVersionSnippet

      @angularTemplateService.insertTemplateInstance @historyVersionSnippet, $previewRoot, new ChoroplethMap
        id: @historyVersionSnippet.id
        mapMediatorService: @mapMediatorService
      historyReady.resolve(@historyVersionSnippet)

    historyReady.promise

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
      # NOTE: this will only work for one mocked map since in the mock the snippt id is always the same
      if snippetJson.id == @snippet.id
        # NOTE: here we change the id in order not to conflict with the version on the page
        snippetJson.id = "#{snippetJson.id}-101"
        # TODO: make a bit of a safer key function
        @historyVersionSnippet = doc.snippetFromJson(snippetJson, doc.document.design)


  removeHistoryVersionInstance: ->
    @angularTemplateService.removeAngularTemplate(@historyVersionSnippet)
    delete @historyVersionSnippet


  revertChange: (property) ->
    key = property.key
    newData = {}
    newData[property.key] = @historyVersionSnippet.data(property.key)
    @latestVersionSnippet.data(newData)
    # NOTE: we need to fire the change event manually since the latestVersionSnippet
    # is note in the snippetTree. This is kind of a hack and should be made better when
    # the engine allows multiple documents.
    doc.document.snippetTree.snippetDataChanged.fire(@latestVersionSnippet, ['projection'])
    property.difference = undefined
    property.info = "(#{newData[property.key]})"
