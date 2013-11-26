describe 'MergeController', ->

  beforeEach ->
    @snippetModel = doc.create('livingmaps.choropleth')
    @snippetModel.data
      map: biggerSampleMap
      data: sample1DData
      projection: 'mercator'
      mappingPropertyOnMap: 'id'
      valueProperty: 'value'
      colorScheme: 'YlGn'
    @olderSnippetModel = @snippetModel.copy(doc.document.design)
    @scope = retrieveService('$rootScope').$new()
    @scope.latestSnippetVersion = @snippetModel
    @scope.historyVersionSnippet = @olderSnippetModel
    @mapMediatorService = retrieveService('mapMediatorService')
    @choroplethMap = new ChoroplethMap
      id: @snippetModel.id
      mapMediatorService: @mapMediatorService
    @mapMediatorService.set(@snippetModel.id, @snippetModel, @choroplethMap, {})
    @mergeController = instantiateController('MergeController', $scope: @scope,
      mapMediatorService: @mapMediatorService)

  describe 'Map Section', ->

    beforeEach ->
      @snippetModel.data
        projection: 'orthographic'
        map: smallerSampleMap

    it 'reverts a change in map geometry', ->
      @mergeController.revertChange
        key: 'map'
      expect(@snippetModel.data('map')).to.eql(biggerSampleMap)


    it 'reverts a change in projection', ->
      @mergeController.revertChange
        key: 'projection'
      expect(@snippetModel.data('projection')).to.equal('mercator')


  describe 'Mapping Section', ->

    beforeEach ->
      @snippetModel.data
        mappingPropertyOnMap: 'alternativeId'

    it 'reverts a change in mapping', ->
      @mergeController.revertChange
        key: 'mappingPropertyOnMap'
      expect(@snippetModel.data('mappingPropertyOnMap')).to.equal('id')


  describe 'Visualization Section', ->

    beforeEach ->
      @snippetModel.data
        valueProperty: 'alternativeValue'
        colorScheme: 'Set1'


    it 'reverts a change in value property', ->
      @mergeController.revertChange
        key: 'valueProperty'
      expect(@snippetModel.data('valueProperty')).to.equal('value')


    it 'reverts a change in color scheme', ->
      @mergeController.revertChange
        key: 'colorScheme'
      expect(@snippetModel.data('colorScheme')).to.equal('YlGn')


  describe 'Ordinal Data', ->

    beforeEach ->
      @snippetModel.data
        valueProperty: 'reverseId'

    # TODO: the display of quantize steps depends on value type
    it 'does not display the revertChange button for a quantizeStep if the value property is ordinal', ->
      @scope.$digest()
      expect(@scope.valueType).to.equal('categorical')

