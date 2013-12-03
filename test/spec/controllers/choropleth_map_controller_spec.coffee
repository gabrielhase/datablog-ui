describe 'ChoroplethMapController', ->

  beforeEach ->
    @mapMediatorService = retrieveService('mapMediatorService')
    @snippetModel = doc.create('livingmaps.choropleth')
    doc.document.snippetTree.root.append(@snippetModel)
    @snippetModel.data
      map: sampleMap
      mapName: 'aGreatName'

    @ngProgress = mockNgProgress()
    @choroplethMap = new ChoroplethMap(@snippetModel.id)
    @scope = retrieveService('$rootScope').$new()
    @scope.mapId = @snippetModel.id
    @mapMediatorService.set(@snippetModel.id, @snippetModel, @choroplethMap, @scope)

    @choroplethController = instantiateController('ChoroplethMapController',
      $scope: @scope, ngProgress: @ngProgress)


  describe 'kickstarter initializations', ->

    it 'initializes the projection to "mercator"', ->
      expect(@snippetModel.data('projection')).to.equal('mercator')


    it 'initializes the color scheme to "Paired" for ordinal data', ->
      @snippetModel.data
        data: sampleCategoricalData
        mappingPropertyOnMap: 'id'
        mappingPropertyOnData: 'id'
        valueProperty: 'party'
      @scope.$digest()
      expect(@snippetModel.data('colorScheme')).to.equal('Paired')


    it 'initializes the color scheme to "YlGn" for numerical data', ->
      @snippetModel.data
        data: sample1DData
        mappingPropertyOnData: 'id'
        mappingPropertyOnMap: 'id'
      expect(@snippetModel.data('colorScheme')).to.equal('YlGn')


    it 'initializes the color steps to 9 for numerical data', ->
      @snippetModel.data
        data: sample1DData
        mappingPropertyOnData: 'id'
        mappingPropertyOnMap: 'id'
      expect(@snippetModel.data('colorSteps')).to.equal(9)


    it 'initializes the value property to the first numerical column in the data', ->
      @snippetModel.data
        data: sample1DData
        mappingPropertyOnData: 'id'
        mappingPropertyOnMap: 'id'
      expect(@snippetModel.data('valueProperty')).to.equal('id')


  # this represents all calls that actually are performed by the choropleth_form_controller
  describe 'call changeChoroplethAttrsData data with changes array', ->

    it 'should react to a map change', ->
      changeChoroplethAttrsData = sinon.spy(@choroplethController, 'changeChoroplethAttrsData')
      @snippetModel.data
        map: biggerSampleMap
      expect(changeChoroplethAttrsData).to.have.been.calledWith(['map'])


    it 'should react to a projection change', ->
      changeChoroplethAttrsData = sinon.spy(@choroplethController, 'changeChoroplethAttrsData')
      @snippetModel.data
        projection: 'a different projection'
      expect(changeChoroplethAttrsData).to.have.been.calledWith(['projection'])


    it 'should react to a predefined map change (map, projection, mapName)', ->
      changeChoroplethAttrsData = sinon.spy(@choroplethController, 'changeChoroplethAttrsData')
      @snippetModel.data
        projection: 'a different projection'
        map: biggerSampleMap
        mapName: 'another map name'
      expect(changeChoroplethAttrsData).to.have.been.calledWith(['projection', 'map', 'mapName'])


    it 'should react to a data change', ->
      changeChoroplethAttrsData = sinon.spy(@choroplethController, 'changeChoroplethAttrsData')
      @snippetModel.data
        data: sampleCategoricalData
      expect(changeChoroplethAttrsData).to.have.been.calledWith(['data'])


    it 'should react to a mappingPropertyOnMap change', ->
      changeChoroplethAttrsData = sinon.spy(@choroplethController, 'changeChoroplethAttrsData')
      @snippetModel.data
        mappingPropertyOnMap: 'a different mappingPropertyOnMap'
      expect(changeChoroplethAttrsData).to.have.been.calledWith(['mappingPropertyOnMap'])


    it 'should react to a mappingPropertyOnData change', ->
      changeChoroplethAttrsData = sinon.spy(@choroplethController, 'changeChoroplethAttrsData')
      @snippetModel.data
        mappingPropertyOnData: 'a different mappingPropertyOnData'
      expect(changeChoroplethAttrsData).to.have.been.calledWith(['mappingPropertyOnData'])


    it 'should react to a valueProperty change', ->
      changeChoroplethAttrsData = sinon.spy(@choroplethController, 'changeChoroplethAttrsData')
      @snippetModel.data
        valueProperty: 'a different value property'
      expect(changeChoroplethAttrsData).to.have.been.calledWith(['valueProperty'])


  describe 'change the directives scopes attributes', ->

    it 'should not perform a change if the changedProperties list is empty', ->
      neverChangedMap =
        name: 'neverThere'
      @snippetModel.data
        jodeliho: 'something irrelevant'
      expect(@scope.map).not.to.eql(neverChangedMap)


    it 'should change the map attr on a map change', ->
      @snippetModel.data
        map: biggerSampleMap
      expect(@scope.map).to.eql(biggerSampleMap)


    it 'should change the data attr on a data change', ->
      newData = [
        name: 'newData'
      ]
      @snippetModel.data
        data: newData
      expect(@scope.data).to.eql(newData)


    it 'should change the projection attr on a projection change', ->
      newProjection =
        name: 'orthographical'
      @snippetModel.data
        projection: newProjection
      expect(@scope.projection).to.eql(newProjection)


    it 'should change the mappingPropertyOnMap attr on a mappingPropertyOnMap change', ->
      newMappingPropertyOnMap =
        name: 'anotherProperty'
      @snippetModel.data
        mappingPropertyOnMap: newMappingPropertyOnMap
      expect(@scope.mappingPropertyOnMap).to.eql(newMappingPropertyOnMap)


    it 'should change the mappingPropertyOnData attr on a mappingPropertyOnData change', ->
      newMappingPropertyOnData =
        name: 'anotherProperty'
      @snippetModel.data
        mappingPropertyOnData: newMappingPropertyOnData
      expect(@scope.mappingPropertyOnData).to.eql(newMappingPropertyOnData)


    it 'should change the valueProperty attr on a valueProperty change', ->
      newValueProperty =
        name: 'anotherProperty'
      @snippetModel.data
        valueProperty: newValueProperty
      expect(@scope.valueProperty).to.eql(newValueProperty)


    it 'changes the color steps attribute on a colorSteps change', ->
      newColorSteps = 12
      @snippetModel.data
        colorSteps: newColorSteps
      expect(@scope.colorSteps).to.eql(newColorSteps)


    it 'changes the color scheme attribute on a colorScheme change', ->
      newColorScheme = 'YlGn'
      @snippetModel.data
        colorScheme: newColorScheme
      expect(@scope.colorScheme).to.eql(newColorScheme)



