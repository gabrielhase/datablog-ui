describe 'Choropleth form controller', ->

  beforeEach ->
    @choroplethMap = new ChoroplethMap()
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
        @storedData[type]

    @ngProgress = mockNgProgress()
    @scope = retrieveService('$rootScope').$new()
    @scope.snippet =
        model: @snippetModel


  describe 'initializations', ->

    describe "skips some when map is not set", ->

      beforeEach ->
        @snippetModel.storedData.map = undefined
        @choroplethController = instantiateController('ChoroplethFormController',
          $scope: @scope, $http: {}, ngProgress: @ngProgress, dataService: {})


      it 'should not initialize mappingPropertyOnMap', ->
        expect(@scope.mappingPropertyOnMap).to.be.undefined


      ['projection', 'mapName', 'mappingPropertyOnData', 'valueProperty'].forEach (key) ->
        it "should initialize #{key}", ->
          expect(@scope[key]).to.eql(@snippetModel.storedData[key])


    describe "skips some when data is not set", ->

      beforeEach ->
        @snippetModel.storedData.data = undefined
        @snippetModel.storedData.map = 'someMap'
        @choroplethController = instantiateController('ChoroplethFormController',
          $scope: @scope, $http: {}, ngProgress: @ngProgress, dataService: {})


      ['mappingPropertyOnData', 'valueProperty'].forEach (key) ->
        it "should not initialize #{key}", ->
          expect(@scope[key]).to.be.undefined


      ['mappingPropertyOnData', 'valueProperty'].forEach (key) ->
        it "should not initialize #{key}", ->
          expect(@scope[key]).to.be.undefined


      ['projection', 'mapName', 'mappingPropertyOnMap'].forEach (key) ->
          it "should initialize #{key}", ->
            expect(@scope[key]).to.eql(@snippetModel.storedData[key])


    describe 'initializes all when map and data are set', ->

      beforeEach ->
        @choroplethController = instantiateController('ChoroplethFormController',
          $scope: @scope, $http: {}, ngProgress: @ngProgress, dataService: {})


      ['projection', 'mapName', 'mappingPropertyOnMap', 'mappingPropertyOnData', 'valueProperty'].forEach (key) ->
          it "should initialize #{key}", ->
            expect(@scope[key]).to.eql(@snippetModel.storedData[key])


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


  # TODO: there seems to be some timing issue when changing user input...
  # describe 'user input', ->

  #   beforeEach ->
  #     @choroplethController = instantiateController('ChoroplethFormController',
  #       $scope: @scope, $http: {}, ngProgress: @ngProgress, dataService: {})


  #   describe 'changes projection', ->

  #     it 'should change the projection on input', ->
  #       @scope.projection = 'fancyNewProjection'
  #       @scope.$digest()
  #       expect(@scope.snippet.model.data('projection')).to.eql('fancyNewProjection')



