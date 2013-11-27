describe 'HistoryModalController', ->

  beforeEach ->
    @snippetModel = doc.create('livingmaps.choropleth')
    @snippetModel.data
      map: sampleMap
      projection: 'mercator'
      mapName: 'aGreatName'
      data: sample1DData
      mappingPropertyOnMap: 'someProp'
      mappingPropertyOnData: 'someProp'
      valueProperty: 'value'
      quantizeSteps: 9
      colorScheme: 'YlGn'
    $q = retrieveService('$q')
    openPromise = $q.defer()
    openPromise.resolve(true)
    @modalInstance =
      opened: openPromise.promise
      dismiss: ->
        true
    @editorService =
      getCurrentDocument: ->
        id: 4
    @scope = retrieveService('$rootScope').$new()
    @timeout = retrieveService('$timeout')
    @q = retrieveService('$q')
    @documentService = retrieveService('documentService')
    @uiStateService = retrieveService('uiStateService')
    @angularTemplateService = retrieveService('angularTemplateService')
    @mapMediatorService = retrieveService('mapMediatorService')
    @choroplethMap = new ChoroplethMap
      id: @snippetModel.id
      mapMediatorService: @mapMediatorService
    @mapMediatorService.set(@snippetModel.id, @snippetModel, @choroplethMap, @scope)
    @historyModalController = instantiateController('HistoryModalController',
      $scope: @scope, $modalInstance: @modalInstance, $timeout: @timeout, $q: @q, snippet: @snippetModel,
      documentService: @documentService, editorService: @editorService,
      uiStateService: @uiStateService, angularTemplateService: @angularTemplateService,
      mapMediatorService: @mapMediatorService)


  describe 'searchHistorySnippet', ->

    beforeEach ->
      @json =
        "identifier": "livingmaps.column"
        "containers":
          "default": [
            "identifier": "livingmaps.choropleth"
          ,
            "identifier": "livingmaps.title"
            "content": {"title": "livingmaps"}
          ,
            "identifier": "livingmaps.choropleth"
            "id": @snippetModel.id
            "data": {"testId": "I am the one"}
          ]

      @jsonWith2Containers =
       "identifier": "livingmaps.mainAndSidebar"
       "containers":
         "main": [
           "identifier": "livingmaps.text"
          ,
           "identifier": "livingmaps.text"
          ,
           "identifier": "livingmaps.text"
         ],
         "sidebar": [
          "identifier": "livingmaps.image"
         ,
          "identifier": "livingmaps.choropleth"
          "id": @snippetModel.id
          "data": {"testId": "I am the one"}
         ]


    it 'creates a snippet copy from the snippet model found by id', ->
      @historyModalController.searchHistorySnippet(@json)
      expect(@scope.historyVersionSnippet.data('testId')).to.equal('I am the one')


    it 'creates a snippet copy from the snippet model found by id in the sidebar', ->
      @historyModalController.searchHistorySnippet(@json)
      expect(@scope.historyVersionSnippet.data('testId')).to.equal('I am the one')


    it 'assigns a novel id to the snippet copy', ->
      @historyModalController.searchHistorySnippet(@json)
      expect(@scope.historyVersionSnippet.id).not.to.equal(@snippetModel.id)


  describe 'Merging changes', ->

    beforeEach ->
      @scope.latestSnippetVersion = @snippetModel.copy(doc.document.design)
      @mapMediatorService.set(@scope.latestSnippetVersion.id, @scope.latestSnippetVersion, @choroplethMap, @scope)
      @event =
        stopPropagation: ->
          true


    it 'merges a map change into the snippet model on the page', ->
      @scope.latestSnippetVersion.data
        map: biggerSampleMap
      @historyModalController.merge(@event)
      expect(@snippetModel.data('map')).to.eql(biggerSampleMap)


    it 'merges a projection change into the snippet model on the page', ->
      @scope.latestSnippetVersion.data
        projection: 'orthographic'
      @historyModalController.merge(@event)
      expect(@snippetModel.data('projection')).to.equal('orthographic')


