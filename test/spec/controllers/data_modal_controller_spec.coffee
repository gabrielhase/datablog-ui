describe 'Data Modal Controller', ->

  beforeEach ->
    @snippetModel = doc.create('livingmaps.choropleth')
    doc.document.snippetTree.root.append(@snippetModel)
    @snippetModel.data
      map: biggerSampleMap
      data: sample1DData

    @scope = retrieveService('$rootScope').$new()
    @mapMediatorService = retrieveService('mapMediatorService')
    @choroplethMap = new ChoroplethMap
      id: @snippetModel.id
      mapMediatorService: @mapMediatorService
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
      @oldSampleDataValue = @sampleDataRow.value

      @sampleMessyRow = switzerlandData[1]
      @oldMessyDataValue = @sampleMessyRow['Residents']


    afterEach ->
      # reset test data values
      @sampleDataRow.value = @oldSampleDataValue
      @sampleMessyRow['Residents'] = @oldMessyDataValue


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
      @snippetModel.data
        data: switzerlandData
      @dataModalController = instantiateController('DataModalController',
        $scope: @scope, $modalInstance: @modalInstance, mapMediatorService: @mapMediatorService,
        highlightedRows: [], mapId: @snippetModel.id, mappedColumn: 'Canton')

      @scope.visualizedData[1]['Residents'] = 45
      @dataModalController.updateEntity(@scope.visualizedData[1])
      @dataModalController.close(@event)
      newData = @snippetModel.data('data')
      expect(newData[1]['Residents']).to.eql(45)



