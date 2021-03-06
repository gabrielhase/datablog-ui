describe 'ChoroplethFormController', ->

  beforeEach ->
    @mapMediatorService = retrieveService('mapMediatorService')
    @snippetModel = doc.create('livingmaps.choropleth')
    doc.document.snippetTree.root.append(@snippetModel)
    @snippetModel.data
      map: sampleMap
      projection: 'mercator'
      mapName: 'aGreatName'
      data: sample1DData
      mappingPropertyOnMap: 'someProp'
      mappingPropertyOnData: 'someProp'
      valueProperty: 'value'
      colorSteps: 9
      colorScheme: 'YlGn'

    @choroplethMap = new ChoroplethMap(@snippetModel.id)

    @ngProgress = mockNgProgress()
    @scope = retrieveService('$rootScope').$new()
    @scope.snippet =
      model: @snippetModel
    @mapMediatorService.set(@snippetModel.id, @snippetModel, @choroplethMap, @scope)

  describe 'initializations', ->

    describe 'when map is not set', ->

      beforeEach ->
        @snippetModel.data
          map: undefined
        @choroplethController = instantiateController('ChoroplethFormController',
          $scope: @scope, $http: {}, ngProgress: @ngProgress, dataService: {})

      it 'does not initialize mappingPropertyOnMap', ->
        expect(@scope.mappingPropertyOnMap).to.be.undefined


      ['projection', 'mapName'].forEach (key) ->
        it "initializes #{key}", ->
          expect(@scope[key]).to.eql(@snippetModel.data(key))


    describe "when data is not set", ->

      beforeEach ->
        @snippetModel.data(
          data: undefined
        )
        @choroplethController = instantiateController('ChoroplethFormController',
          $scope: @scope, $http: {}, ngProgress: @ngProgress, dataService: {})


      ['mappingPropertyOnData', 'valueProperty', 'colorSteps', 'colorScheme'].forEach (key) ->
        it "does not initialize #{key}", ->
          expect(@scope[key]).to.be.undefined


      ['projection', 'mapName', 'mappingPropertyOnMap'].forEach (key) ->
          it "initializes #{key}", ->
            expect(@scope[key]).to.eql(@snippetModel.data(key))


    describe 'when map and data are set', ->

      beforeEach ->
        @choroplethController = instantiateController('ChoroplethFormController',
          $scope: @scope, $http: {}, ngProgress: @ngProgress, dataService: {})


      ['projection', 'mapName', 'mappingPropertyOnMap', 'mappingPropertyOnData', 'valueProperty', 'colorSteps', 'colorScheme'].forEach (key) ->
          it "initializes #{key}", ->
            expect(@scope[key]).to.eql(@snippetModel.data(key))


      it 'initializes isCategorical to false with numeric valueProperty', ->
        expect(@scope.isCategorical).to.be.false


    describe 'form selection lists', ->

      describe 'for map properties', ->

        beforeEach ->
          @choroplethController = instantiateController('ChoroplethFormController',
            $scope: @scope, $http: {}, ngProgress: @ngProgress, dataService: {})

        it 'initializes available projections', ->
          expect(@scope.projections).to.eql(choroplethMapConfig.availableProjections)


        it 'initializes available mapping properties on map', ->
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


      describe 'for data properties', ->

        beforeEach ->
          @choroplethController = instantiateController('ChoroplethFormController',
            $scope: @scope, $http: {}, ngProgress: @ngProgress, dataService: {})


        it 'initializes available data properties', ->
          expect(@scope.availableDataProperties).to.eql([
            label: 'id (e.g. 2)'
            key: 'id'
          ,
            label: 'alternativeId (e.g. 1)'
            key: 'alternativeId'
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


        it 'initializes available color schemes', ->
          expect(@scope.availableColorSchemes).to.eql(colorBrewerConfig.colorSchemes)


        it 'initializes max color step according to color scheme', ->
          expect(@scope.maxColorSteps).to.eql(9)


  describe 'mapping property on data', ->

    it 'notifies the user when no mappings are possible', ->
      @snippetModel.data
        data: switzerlandData
        map: sampleMap
        mappingPropertyOnMap: 'id'
      @choroplethController = instantiateController('ChoroplethFormController',
            $scope: @scope, $http: {}, ngProgress: @ngProgress, dataService: {})
      expect(@scope.availableDataMappingProperties).to.eql([])


    it 'recognizes the suitable mapping property when only one is possible', ->
      @snippetModel.data
        data: messyData
        map: biggerSampleMap
        mappingPropertyOnMap: 'id'
      @choroplethController = instantiateController('ChoroplethFormController',
            $scope: @scope, $http: {}, ngProgress: @ngProgress, dataService: {})
      expect(@scope.availableDataMappingProperties).to.eql([
        label: 'an id (e.g. 2)'
        key: 'an id'
      ])


    it 'selects the suitable mapping when only one is possible on the scope', ->
      @snippetModel.data
        data: messyData
        map: biggerSampleMap
        mappingPropertyOnMap: 'id'
      @choroplethController = instantiateController('ChoroplethFormController',
            $scope: @scope, $http: {}, ngProgress: @ngProgress, dataService: {})
      expect(@scope.mappingPropertyOnData).to.eql('an id')


    it 'selects the suitable mapping when only one is possible on the snippet model', ->
      @snippetModel.data
        data: messyData
        map: biggerSampleMap
        mappingPropertyOnMap: 'id'
      @choroplethController = instantiateController('ChoroplethFormController',
            $scope: @scope, $http: {}, ngProgress: @ngProgress, dataService: {})
      @scope.$digest()
      expect(@snippetModel.data('mappingPropertyOnData')).to.eql('an id')


    it 'populates a select list with all possible mappings', ->
      @snippetModel.data
        data: sample1DData
        map: sampleMap
        mappingPropertyOnMap: 'id'
      @choroplethController = instantiateController('ChoroplethFormController',
            $scope: @scope, $http: {}, ngProgress: @ngProgress, dataService: {})
      expect(@scope.availableDataMappingProperties).to.eql([
        label: 'id (e.g. 2)',
        key: 'id'
      ,
        label: 'alternativeId (e.g. 1)'
        key: 'alternativeId'
      ])


  describe 'user input', ->

    beforeEach ->
      @snippetModel.data
        mappingPropertyOnMap: 'id'
      @choroplethController = instantiateController('ChoroplethFormController',
        $scope: @scope, $http: {}, ngProgress: @ngProgress, dataService: {})
      colorBrewerConfig.colorSchemes.push
        name: 'Test'
        cssClass: 'test'
        steps: 3

    describe 'on projection', ->

      it 'changes the projection on snippet', ->
        @scope.projection = 'albersUsa'
        @scope.$digest()
        expect(@scope.snippet.model.data('projection')).to.eql('albersUsa')


    describe 'on mapping property on map', ->

      it 'changes the mappingPropertyOnMap on snippet', ->
        @scope.mappingPropertyOnMap = 'fancyNewId'
        @scope.$digest()
        expect(@scope.snippet.model.data('mappingPropertyOnMap')).to.eql('fancyNewId')


      it 'changes available data mapping properties', ->
        @scope.mappingPropertyOnMap = 'name'
        @scope.$digest()
        expect(@scope.availableDataMappingProperties).to.eql([])


    describe 'on data upload', ->

      it 'changes the data', ->
        @choroplethController.setData(messyData)
        expect(@scope.snippet.model.data('data')).to.eql(messyData)


      it 'changes the mapping property on data', ->
        @choroplethController.setData(messyData)
        expect(@scope.availableDataMappingProperties).to.eql([
          label: 'an id (e.g. 2)'
          key: 'an id'
        ])


    describe 'on mapping property on data', ->

      it 'changes the mappingPropertyOnData on snippet', ->
        @scope.mappingPropertyOnData = 'fancyNewDataId'
        @scope.$digest()
        expect(@scope.snippet.model.data('mappingPropertyOnData')).to.eql('fancyNewDataId')


    describe 'on value property on data', ->

      beforeEach ->
        @snippetModel.data
          data: valueTypeSamples

      it 'changes the valueProperty on snippet', ->
        @scope.valueProperty = 'fancyNewvalueProperty'
        @scope.$digest()
        expect(@scope.snippet.model.data('valueProperty')).to.eql('fancyNewvalueProperty')


      it 'sets isCategorical to true when changing to a categorical property', ->
        @scope.valueProperty = 'categorical'
        @scope.$digest()
        expect(@scope.isCategorical).to.be.true


      it 'sets isCategorical to false when changing to a numerical property', ->
        @scope.valueProperty = 'numerical'
        @scope.$digest()
        expect(@scope.isCategorical).to.be.false


      it 'returns hasTooManyCategories true when there are too many categories', ->
        @scope.colorScheme = 'test'
        @scope.valueProperty = 'categoricalUnique'
        @scope.$digest()
        expect(@scope.hasTooManyCategories()).to.be.true


    describe 'on color scheme on data', ->

      beforeEach ->
        @snippetModel.data
          data: valueTypeSamples
        @scope.valueProperty = 'categoricalUnique'

      it 'changes the color scheme on snippet', ->
        @scope.colorScheme = 'Paired'
        @scope.$digest()
        expect(@scope.snippet.model.data('colorScheme')).to.eql('Paired')


      it 'changes the max color steps according to color scheme', ->
        @scope.colorScheme = 'Paired'
        @scope.$digest()
        expect(@scope.maxColorSteps).to.eql(12)


      it 'resets the color steps to max value of color scheme if necessary', ->
        # make it high
        @scope.colorScheme = 'Paired'
        @scope.colorSteps = 12
        @scope.$digest()
        @scope.colorScheme = 'YlGn'
        @scope.$digest()
        expect(@scope.colorSteps).to.eql(9)


      it 'returns hasTooManyCategories true when there are too little color steps', ->
        @scope.colorScheme = 'test'
        @scope.$digest()
        expect(@scope.hasTooManyCategories()).to.be.true


    describe 'on color steps on data', ->

      it 'changes the color steps on snippet', ->
        @scope.colorSteps = 5
        @scope.$digest()
        expect(@scope.snippet.model.data('colorSteps')).to.eql(5)

