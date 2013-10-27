describe 'Choropleth map controller', ->

  beforeEach ->
    @mapMediatorService = retrieveService('mapMediatorService')
    @snippetModel = doc.create('livingmaps.choropleth')
    doc.document.snippetTree.root.append(@snippetModel)
    @snippetModel.data
      map: 'aMap'
      projection: 'mercator'
      mapName: 'aGreatName'
      data: 'someData'
      mappingPropertyOnMap: 'someProp'
      mappingPropertyOnData: 'someProp'
      valueProperty: 'someVal'
      quantizeSteps: 9
      colorScheme: 'boringColors'

    @ngProgress = mockNgProgress()
    @choroplethMap = new ChoroplethMap
      id: @snippetModel.id
      mapMediatorService: @mapMediatorService
    @scope =
      mapId: @snippetModel.id
    @mapMediatorService.set(@snippetModel.id, @snippetModel, @choroplethMap, @scope)

    @choroplethController = instantiateController('ChoroplethMapController',
      $scope: @scope, ngProgress: @ngProgress)


  # this represents all calls that actually are performed by the choropleth_form_controller
  describe 'call changeChoroplethAttrsData data with changes array', ->

    it 'should react to a map change', ->
      changeChoroplethAttrsData = sinon.spy(@choroplethController, 'changeChoroplethAttrsData')
      @snippetModel.data
        map: 'another map'
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
        map: 'another map'
        mapName: 'another map name'
      expect(changeChoroplethAttrsData).to.have.been.calledWith(['projection', 'map', 'mapName'])


    it 'should react to a data change', ->
      changeChoroplethAttrsData = sinon.spy(@choroplethController, 'changeChoroplethAttrsData')
      @snippetModel.data
        data: 'different data'
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
      newMap =
        name: 'newMap'
      @snippetModel.data
        map: newMap
      expect(@scope.map).to.eql(newMap)


    it 'should change the data attr on a data change', ->
      newData =
        name: 'newData'
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


    it 'changes the quantize steps attribute on a quantizeSteps change', ->
      newQuantizeSteps = 12
      @snippetModel.data
        quantizeSteps: newQuantizeSteps
      expect(@scope.quantizeSteps).to.eql(newQuantizeSteps)


    it 'changes the color scheme attribute on a colorScheme change', ->
      newColorScheme = 'fancyColors'
      @snippetModel.data
        colorScheme: newColorScheme
      expect(@scope.colorScheme).to.eql(newColorScheme)



