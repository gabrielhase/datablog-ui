angular.module('ldEditor').controller 'HistoryModalController',
class HistoryModalController

  constructor: (@$scope, @$modalInstance, @$timeout, @$q, @snippet, @documentService,
    @editorService, @uiStateService, @angularTemplateService, @mapMediatorService, @leafletData) ->
    @$scope.modalState =
      isMerging: false
    @$scope.snippet = @snippet
    @$scope.merge = $.proxy(@merge, this)
    @$scope.close = $.proxy(@close, this)
    @$scope.chooseRevision = $.proxy(@chooseRevision, this)
    @$scope.isSelected = $.proxy(@isSelected, this)

    @$scope.modalContentReady = $.Callbacks('memory once')
    @$scope.rightBeforeMerge = $.Callbacks('memory once')
    @originalModelInstance = @mapMediatorService.getUIModel(@$scope.snippet.id)
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
          @$scope.versionDifference = @currentModelInstance.calculateDifference(historyVersion)
          @$scope.modalContentReady.fire()


  # Factory Method
  createModelInstance: (snippetModel) ->
    if snippetModel.identifier == 'livingmaps.choropleth'
      return new ChoroplethMap(snippetModel.id)
    else if snippetModel.identifier == 'livingmaps.map'
      return new WebMap(snippetModel.id)
    else
      log.error "Unsupported Snippet type for history view"


  setupLatestVersion: ->
    # $('.upfront-snippet-history .history-explorer .current-history-map')
    $previewRoot = $('.upfront-snippet-history .latest-preview .latest-version-map')
    @$scope.latestSnippetVersion = @snippet.copy(doc.document.design)
    @$scope.latestSnippetVersion.data
      synchronousHighlight: true
    @currentModelInstance = @createModelInstance(@$scope.latestSnippetVersion) # TODO replace duplication
    @angularTemplateService.insertTemplateInstance(@$scope.latestSnippetVersion, $previewRoot, @createModelInstance(@$scope.latestSnippetVersion))


  removeLatestVersionInstance: ->
    @angularTemplateService.removeAngularTemplate(@$scope.latestSnippetVersion)
    delete @$scope.latestSnippetVersion


  merge: (event) ->
    @$scope.rightBeforeMerge.fire()
    @originalModelInstance.merge(@$scope.latestSnippetVersion)
    @close(event)


  close: (event) ->
    @removeLatestVersionInstance() if @$scope.latestSnippetVersion
    @removeHistoryVersionInstance() if @$scope.historyVersionSnippet
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
      @$scope.versionDifference = @currentModelInstance.calculateDifference(historyVersion)


  addHistoryVersion: (historyRevision) ->
    historyReady = @$q.defer()
    @selectedHistoryRevision = historyRevision
    @documentService.getRevision(@editorService.getCurrentDocument().id, historyRevision.revisionId).then (documentRevision) =>
      $previewRoot = $('.upfront-snippet-history .history-explorer .current-history-map')
      if documentRevision.data.content
        for snippetJson in documentRevision.data.content
          @searchHistorySnippet(snippetJson)

      log.error 'The history document has to contain the map' unless @$scope.historyVersionSnippet

      @$scope.historyVersionSnippet.data
        synchronousHighlight: true

      historyModelInstance = @createModelInstance(@$scope.historyVersionSnippet)
      @angularTemplateService.insertTemplateInstance(@$scope.historyVersionSnippet, $previewRoot, historyModelInstance)
      historyReady.resolve(@$scope.historyVersionSnippet)

    historyReady.promise


  # takes array of snippets or containers and looks for the snippet in the snippet tree
  # that has the same id.
  # Assigns this snippet to @$scope.historyVersionSnippet
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
        @$scope.historyVersionSnippet = doc.snippetFromJson(snippetJson, doc.document.design)


  removeHistoryVersionInstance: ->
    @angularTemplateService.removeAngularTemplate(@$scope.historyVersionSnippet)
    delete @$scope.historyVersionSnippet
