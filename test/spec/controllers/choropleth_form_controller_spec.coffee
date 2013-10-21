describe 'Choropleth form controller', ->

  # TODO: at this point we should use the real livingdocs-engine and not mock out actual functionality
  beforeEach ->
    @choroplethMap = new ChoroplethMap()
    # @snippetModel = doc.document.createModel('choropleth')
    # @snippetModel.id = 'testChoropleth'
    # @snippetModel.uiTemplateInstance = @choroplethMap
    # # @snippetModel.data(
    #   map: sampleMap
    #   projection: 'aProjection'
    #   mapName: 'aGreatName'
    #   data: sample1DData
    #   mappingPropertyOnMap: 'someProp'
    #   mappingPropertyOnData: 'someProp'
    #   valueProperty: 'someVal'
    # )
    @snippetModel =
      id: 'testChoropleth'
      uiTemplateInstance: @choroplethMap
      storedData:
        map: sampleMap
        projection: 'aProjection'
        mapName: 'aGreatName'
        data: sample1DData
        mappingPropertyOnMap: 'someProp'
        mappingPropertyOnData: 'someProp'
        valueProperty: 'someVal'
      data: (type) ->
        if typeof(type) == 'object'
          for key, value of type
            @storedData[key] = value
        else
          @storedData[type]

    @ngProgress = mockNgProgress()
    @scope = retrieveService('$rootScope').$new()
    @scope.snippet =
        model: @snippetModel


  describe 'initializations', ->

    describe "when map is not set", ->

      beforeEach ->
        #@snippetModel.storedData.map = undefined
        @snippetModel.data(
          map: undefined
        )
        @choroplethController = instantiateController('ChoroplethFormController',
          $scope: @scope, $http: {}, ngProgress: @ngProgress, dataService: {})


      it 'initializes mappingPropertyOnMap', ->
        expect(@scope.mappingPropertyOnMap).to.be.undefined


      ['projection', 'mapName', 'mappingPropertyOnData', 'valueProperty'].forEach (key) ->
        it "does not initialize #{key}", ->
          #expect(@scope[key]).to.eql(@snippetModel.storedData[key])
          expect(@scope[key]).to.eql(@snippetModel.data(key))


    describe "when data is not set", ->

      beforeEach ->
        #@snippetModel.storedData.data = undefined
        #@snippetModel.storedData.map = 'someMap'
        @snippetModel.data(
          data: undefined
        )
        @choroplethController = instantiateController('ChoroplethFormController',
          $scope: @scope, $http: {}, ngProgress: @ngProgress, dataService: {})


      ['mappingPropertyOnData', 'valueProperty'].forEach (key) ->
        it "does not initialize #{key}", ->
          expect(@scope[key]).to.be.undefined


      ['projection', 'mapName', 'mappingPropertyOnMap'].forEach (key) ->
          it "initializes #{key}", ->
            expect(@scope[key]).to.eql(@snippetModel.data(key))


    describe 'initializes all when map and data are set', ->

      beforeEach ->
        @choroplethController = instantiateController('ChoroplethFormController',
          $scope: @scope, $http: {}, ngProgress: @ngProgress, dataService: {})


      ['projection', 'mapName', 'mappingPropertyOnMap', 'mappingPropertyOnData', 'valueProperty'].forEach (key) ->
          it "should initialize #{key}", ->
            expect(@scope[key]).to.eql(@snippetModel.data(key))


    describe 'initialize property selection lists', ->

      describe 'for map selections', ->

        beforeEach ->
          @choroplethController = instantiateController('ChoroplethFormController',
            $scope: @scope, $http: {}, ngProgress: @ngProgress, dataService: {})

        it 'should initialize available projections', ->
          expect(@scope.projections).to.eql(choroplethMapConfig.availableProjections)


        it 'should initialize available mapping properties on map', ->
          expect(@scope.availableMapProperties).to.eql([
            label: 'id (e.g. 1)'
            value: 'id'
          ,
            label: 'name (e.g. Alabama)'
            value: 'name'
          ,
            label: 'reverseMapping (e.g. String2)'
            value: 'reverseMapping'
          ])


      describe 'for data selections', ->

        beforeEach ->
          @choroplethController = instantiateController('ChoroplethFormController',
            $scope: @scope, $http: {}, ngProgress: @ngProgress, dataService: {})


        it 'should initialize available data properties', ->
          expect(@scope.availableDataProperties).to.eql([
            label: 'id (e.g. 2)'
            key: 'id'
          ,
            label: 'reverseId (e.g. String2)'
            key: 'reverseId'
          ,
            label: 'value (e.g. 7)'
            key: 'value'
          ,
            label: 'alternativeValue (e.g. 5)'
            key: 'alternativeValue'
          ])


  describe 'user input', ->

    beforeEach ->
      @choroplethController = instantiateController('ChoroplethFormController',
        $scope: @scope, $http: {}, ngProgress: @ngProgress, dataService: {})


    describe 'on projection', ->

      it 'changes the projection on snippet', ->
        @scope.projection = 'fancyNewProjection'
        @scope.$digest()
        expect(@scope.snippet.model.data('projection')).to.eql('fancyNewProjection')


    describe 'on mapping property on map', ->

      it 'changes the mappingPropertyOnMap on snippet', ->
        @scope.mappingPropertyOnMap = 'fancyNewId'
        @scope.$digest()
        expect(@scope.snippet.model.data('mappingPropertyOnMap')).to.eql('fancyNewId')


    describe 'on mapping property on data', ->

      it 'changes the mappingPropertyOnData on snippet', ->
        @scope.mappingPropertyOnData = 'fancyNewDataId'
        @scope.$digest()
        expect(@scope.snippet.model.data('mappingPropertyOnData')).to.eql('fancyNewDataId')


    describe 'on value property on data', ->

      it 'changes the valueProperty on snippet', ->
        @scope.valueProperty = 'fancyNewvalueProperty'
        @scope.$digest()
        expect(@scope.snippet.model.data('valueProperty')).to.eql('fancyNewvalueProperty')

