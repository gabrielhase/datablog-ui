describe 'HistoryModalController', ->

  beforeEach ->
    snippetModel = doc.create('livingmaps.choropleth')
    scope = retrieveService('$rootScope').$new()
    documentService = retrieveService('documentService')
    editorService =
      getCurrentDocument: ->
        id: 1
    @uiStateService = retrieveService('uiStateService')
    modalInstance =
      dismiss: ->
        true
    @event =
      stopPropagation: ->
        true
    @historyController = instantiateController('HistoryModalController',
      $scope: scope, $modalInstance: modalInstance, snippet: snippetModel,
      documentService: documentService, editorService: editorService,
      uiStateService: @uiStateService)


  it 'disables autosaving while in modal view', ->
    expect(@uiStateService.state.autosave.active).to.be.false


  it 're-enables autosaving when closing modal', ->
    @historyController.close(@event)
    expect(@uiStateService.state.autosave.active).to.be.true
