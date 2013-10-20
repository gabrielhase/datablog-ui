describe 'Choropleth form controller', ->

  beforeEach ->
    @choroplethMap = new ChoroplethMap()
    @snippetModel =
      id: 'testChoropleth'
      uiTemplateInstance: @choroplethMap
      storedData:
        map: 'aMap'
        projection: 'aProjection'
        mapName: 'aGreatName'
        data: 'someData'
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


      describe '', ->  # NOTE: due to the scoping of params a repeater always has to be alone in a descibe block (scope)
        for key in ['projection', 'mapName', 'mappingPropertyOnData', 'valueProperty']
          it "should initialize #{key}", ->
            expect(@scope[key]).to.eql(@snippetModel.storedData[key])


    describe "skips some when data is not set", ->

      beforeEach ->
        @snippetModel.storedData.data = undefined
        @snippetModel.storedData.map = 'someMap'
        @choroplethController = instantiateController('ChoroplethFormController',
          $scope: @scope, $http: {}, ngProgress: @ngProgress, dataService: {})


      describe '', ->
        for key in ['mappingPropertyOnData', 'valueProperty']
          it "should not initialize #{key}", ->
            expect(@scope[key]).to.be.undefined


      describe '', ->
        for key in ['projection', 'mapName', 'mappingPropertyOnMap']
          it "should initialize #{key}", ->
            expect(@scope[key]).to.eql(@snippetModel.storedData[key])


    describe 'initializes all when map and data are set', ->

      beforeEach ->
        @choroplethController = instantiateController('ChoroplethFormController',
          $scope: @scope, $http: {}, ngProgress: @ngProgress, dataService: {})


      describe '', ->
        for key in ['projection', 'mapName', 'mappingPropertyOnMap', 'mappingPropertyOnData', 'valueProperty']
          it "should initialize #{key}", ->
            expect(@scope[key]).to.eql(@snippetModel.storedData[key])


  # TODO: there seems to be some timing issue when changing user input...
  # describe 'user input', ->

  #   beforeEach ->
  #     @choroplethController = instantiateController('ChoroplethFormController',
  #       $scope: @scope, $http: {}, ngProgress: @ngProgress, dataService: {})


  #   describe 'changes projection', ->

  #     it 'should change the projection on input', ->
  #       console.log "HERE"
  #       @scope.projection = 'fancyNewProjection'
  #       @scope.$digest()
  #       expect(@scope.snippet.model.data('projection')).to.eql('fancyNewProjection')



