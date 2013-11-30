describe 'Data Modal Controller', ->

  beforeEach ->
    @snippetModel = doc.create('livingmaps.choropleth')
    doc.document.snippetTree.root.append(@snippetModel)
    localData = []
    @snippetModel.data
      map: biggerSampleMap
      data: $.extend(true, localData, sample1DData) # since we are changing values we need a deep copy
      projection: 'mercator'
      colorScheme: 'Paired'
      colorSteps: 9
      valueProperty: 'value'

    @scope = retrieveService('$rootScope').$new()
    @mapMediatorService = retrieveService('mapMediatorService')
    @choroplethMap = new ChoroplethMap(@snippetModel.id)
    @mapMediatorService.set(@snippetModel.id, @snippetModel, @choroplethMap)
    @modalInstance =
      dismiss: ->
        true
    @event =
      stopPropagation: ->
        true


  describe 'changing data values', ->

    beforeEach ->
      @sampleDataRow = sample1DData[0]
      @sampleMessyRow = switzerlandData[1]

      @ngProgress = mockNgProgress()
      @choroplethScope = retrieveService('$rootScope').$new()
      @choroplethScope.mapId = @snippetModel.id
      @choroplethController = instantiateController('ChoroplethMapController',
      $scope: @choroplethScope, ngProgress: @ngProgress)


    it 'changes a data property on the snippet upon closing', ->
      @dataModalController = instantiateController('DataModalController',
        $scope: @scope, $modalInstance: @modalInstance, mapMediatorService: @mapMediatorService,
        highlightedRows: [], mapId: @snippetModel.id, mappedColumn: 'id')
      # make a change
      @scope.visualizedData[0].Value = 6
      @dataModalController.updateEntity(@scope.visualizedData[0])
      @dataModalController.close(@event)
      newData = @snippetModel.data('data')
      expect(newData[0].value).to.eql(6)


    it 'changes a data property on the snippet upon closing with switzerlandData', ->
      localData = []
      @snippetModel.data
        data: $.extend(true, localData, switzerlandData)
      @dataModalController = instantiateController('DataModalController',
        $scope: @scope, $modalInstance: @modalInstance, mapMediatorService: @mapMediatorService,
        highlightedRows: [], mapId: @snippetModel.id, mappedColumn: 'Canton')

      @scope.visualizedData[1]['Residents'] = 45
      @dataModalController.updateEntity(@scope.visualizedData[1])
      @dataModalController.close(@event)
      newData = @snippetModel.data('data')
      expect(newData[1]['Residents']).to.eql(45)


    it 'calls the snippet change listener on choropleth map controller', ->
      @dataModalController = instantiateController('DataModalController',
        $scope: @scope, $modalInstance: @modalInstance, mapMediatorService: @mapMediatorService,
        highlightedRows: [], mapId: @snippetModel.id, mappedColumn: 'id')
      changeChoroplethAttrsData = sinon.spy(@choroplethController, 'changeChoroplethAttrsData')
      # make a change
      @scope.visualizedData[0].Value = 6
      @dataModalController.updateEntity(@scope.visualizedData[0])
      @dataModalController.close(@event)
      expect(changeChoroplethAttrsData).to.have.been.calledWith(['data'])






