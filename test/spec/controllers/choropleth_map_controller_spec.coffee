describe 'Choropleth map controller', ->

  beforeEach ->
    @snippetModel =
      id: 'testChoropleth'
      storedData:
        map: 'aMap'
        projection: 'aProjection'
        dataIdentifier: 'aGreatName'
        data: 'someData'
        mappingPropertyOnMap: 'someProp'
        mappingPropertyOnData: 'someProp'
        valueProperty: 'someVal'
      data: (type) ->
        @storedData[type]

    @ngProgress =
      start: ->
        true
      complete: ->
        true
      status: ->
        true

    @choroplethMap = new ChoroplethMap()
    @scope =
      snippetModel: @snippetModel
      templateInstance: @choroplethMap

    @choroplethController = instantiateController('ChoroplethMapController',
      $scope: @scope, ngProgress: @ngProgress)

  # this represents all calls that actually are performed by the choropleth_form_controller
  describe 'call changeChoroplethAttrsData data with changes array', ->

    it 'should react to a map change', ->
      changeChoroplethAttrsData = sinon.spy(@choroplethController, 'changeChoroplethAttrsData')
      doc.changeSnippetData.fire(@snippetModel, ['map'])
      expect(changeChoroplethAttrsData).to.have.been.calledWith(['map'])


    it 'should react to a projection change', ->
      changeChoroplethAttrsData = sinon.spy(@choroplethController, 'changeChoroplethAttrsData')
      doc.changeSnippetData.fire(@snippetModel, ['projection'])
      expect(changeChoroplethAttrsData).to.have.been.calledWith(['projection'])


    it 'should react to a predefined map change (map, projection, dataIdentifier)', ->
      changeChoroplethAttrsData = sinon.spy(@choroplethController, 'changeChoroplethAttrsData')
      doc.changeSnippetData.fire(@snippetModel, ['projection', 'map', 'dataIdentifier'])
      expect(changeChoroplethAttrsData).to.have.been.calledWith(['projection', 'map', 'dataIdentifier'])


    it 'should react to a data change', ->
      changeChoroplethAttrsData = sinon.spy(@choroplethController, 'changeChoroplethAttrsData')
      doc.changeSnippetData.fire(@snippetModel, ['data'])
      expect(changeChoroplethAttrsData).to.have.been.calledWith(['data'])


    it 'should react to a mappingPropertyOnMap change', ->
      changeChoroplethAttrsData = sinon.spy(@choroplethController, 'changeChoroplethAttrsData')
      doc.changeSnippetData.fire(@snippetModel, ['mappingPropertyOnMap'])
      expect(changeChoroplethAttrsData).to.have.been.calledWith(['mappingPropertyOnMap'])


    it 'should react to a mappingPropertyOnData change', ->
      changeChoroplethAttrsData = sinon.spy(@choroplethController, 'changeChoroplethAttrsData')
      doc.changeSnippetData.fire(@snippetModel, ['mappingPropertyOnData'])
      expect(changeChoroplethAttrsData).to.have.been.calledWith(['mappingPropertyOnData'])


    it 'should react to a valueProperty change', ->
      changeChoroplethAttrsData = sinon.spy(@choroplethController, 'changeChoroplethAttrsData')
      doc.changeSnippetData.fire(@snippetModel, ['valueProperty'])
      expect(changeChoroplethAttrsData).to.have.been.calledWith(['valueProperty'])


  describe 'change the directives scopes attributes', ->

    it 'should not perform a change if the changedProperties list is empty', ->
      neverChangedMap =
        name: 'neverThere'
      @snippetModel.storedData.map = neverChangedMap
      doc.changeSnippetData.fire(@snippetModel, [])
      expect(@scope.map).not.to.eql(neverChangedMap)


    it 'should change the map attr on a map change', ->
      newMap =
        name: 'newMap'
      @snippetModel.storedData.map = newMap
      doc.changeSnippetData.fire(@snippetModel, ['map'])
      expect(@scope.map).to.eql(newMap)


    it 'should change the data attr on a data change', ->
      newData =
        name: 'newData'
      @snippetModel.storedData.data = newData
      doc.changeSnippetData.fire(@snippetModel, ['data'])
      expect(@scope.data).to.eql(newData)


    it 'should change the projection attr on a projection change', ->
      newProjection =
        name: 'orthographical'
      @snippetModel.storedData.projection = newProjection
      doc.changeSnippetData.fire(@snippetModel, ['projection'])
      expect(@scope.projection).to.eql(newProjection)


    it 'should change the mappingPropertyOnMap attr on a mappingPropertyOnMap change', ->
      newMappingPropertyOnMap =
        name: 'anotherProperty'
      @snippetModel.storedData.mappingPropertyOnMap = newMappingPropertyOnMap
      doc.changeSnippetData.fire(@snippetModel, ['mappingPropertyOnMap'])
      expect(@scope.mappingPropertyOnMap).to.eql(newMappingPropertyOnMap)


    it 'should change the mappingPropertyOnData attr on a mappingPropertyOnData change', ->
      newMappingPropertyOnData =
        name: 'anotherProperty'
      @snippetModel.storedData.mappingPropertyOnData = newMappingPropertyOnData
      doc.changeSnippetData.fire(@snippetModel, ['mappingPropertyOnData'])
      expect(@scope.mappingPropertyOnData).to.eql(newMappingPropertyOnData)


    it 'should change the valueProperty attr on a valueProperty change', ->
      newValueProperty =
        name: 'anotherProperty'
      @snippetModel.storedData.valueProperty = newValueProperty
      doc.changeSnippetData.fire(@snippetModel, ['valueProperty'])
      expect(@scope.valueProperty).to.eql(newValueProperty)


