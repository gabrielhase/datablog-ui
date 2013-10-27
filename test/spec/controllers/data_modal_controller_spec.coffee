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
    modalInstance =
      dismiss: ->
        true
    @dataModalController = instantiateController('DataModalController',
      $scope: @scope, $modalInstance: modalInstance, mapMediatorService: @mapMediatorService,
      highlightedRows: [], mapId: @snippetModel.id, mappedColumn: 'id')
    @event =
      stopPropagation: ->
        true


  describe 'changing data values', ->

    beforeEach ->
      @sampleDataRow = sample1DData[0]
      @oldSampleDataValue = @sampleDataRow.value
      @sampleMessyRow = messyData[0]
      @oldMessyDataValue = @sampleMessyRow['value']


    afterEach ->
      # reset test data values
      @sampleDataRow.value = @oldSampleDataValue
      @sampleMessyRow['value'] = @oldMessyDataValue


    it 'changes a data property on the snippet upon closing', ->
      # make a change
      @sampleDataRow.value += 3
      @dataModalController.updateEntity(@sampleDataRow)
      @dataModalController.close(@event)
      newData = @snippetModel.data('data')
      expect(newData[0].value).to.eql(@oldSampleDataValue+3)


    it 'changes a data property on the snippet upon closing with messy data', ->
      @snippetModel.data
        data: messyData

      @sampleMessyRow['value'] = '1'
      @dataModalController.updateEntity(@sampleMessyRow)
      @dataModalController.close(@event)
      newData = @snippetModel.data('data')
      expect(newData[0]['value']).to.eql('1')


