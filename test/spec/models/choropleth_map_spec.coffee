describe 'ChoroplethMap', ->

  beforeEach ->
    @mapMediatorService = retrieveService('mapMediatorService')
    @snippetModel = doc.create('livingmaps.choropleth')
    doc.document.snippetTree.root.append(@snippetModel)
    @snippetModel.data
      map: biggerSampleMap
      data: messyData
    @choroplethMap = new ChoroplethMap(@snippetModel.id)
    @mapMediatorService.set(@snippetModel.id, @snippetModel, @choroplethMap)


  it 'gets its associated snippet model', ->
    expect(@choroplethMap._getSnippetModel()).to.eql(@snippetModel)


  describe 'Difference calculation', ->

    beforeEach ->
      @snippetModel.data
        projection: 'mercator'
        mappingPropertyOnMap: 'id'
        mappingPropertyOnData: 'id'
        valueProperty: 'value'
        colorScheme: 'YlGn'
        quantizeSteps: 3
      @oldSnippetModel = {}
      $.extend(true, @oldSnippetModel, @snippetModel)

    describe 'Map Section', ->

      it 'recognizes an unchanged map', ->
        diff = @choroplethMap.calculateDifference(@oldSnippetModel)
        expect(diff[0].properties[0]).to.eql(
          label: 'regions'
          key: 'map'
        )


      it 'calculates the difference between two geometries in the geojson as a blobChange', ->
        @snippetModel.data
          map: smallerSampleMap
        diff = @choroplethMap.calculateDifference(@oldSnippetModel)
        expect(diff[0].properties[0]).to.eql(
          label: 'regions'
          key: 'map'
          difference:
            type: 'blobChange'
        )


      it 'recognizes an unchanged projection', ->
        diff = @choroplethMap.calculateDifference(@oldSnippetModel)
        expect(diff[0].properties[1]).to.eql(
          label: 'projection'
          key: 'projection'
          difference: undefined
          info: "(mercator)"
        )


      it 'calculates the difference between two projections as a change', ->
        @snippetModel.data
          projection: 'orthographic'
        diff = @choroplethMap.calculateDifference(@oldSnippetModel)
        expect(diff[0].properties[1]).to.eql(
          label: 'projection'
          key: 'projection'
          difference:
            type: 'change'
            previous: 'mercator'
            after: 'orthographic'
        )


    describe 'Mapping Section', ->

      it 'recognizes an unchanged mapping', ->
        diff = @choroplethMap.calculateDifference(@oldSnippetModel)
        expect(diff[1].properties[0]).to.eql(
          label: 'mapping'
          key: 'mappingPropertyOnMap'
          difference: undefined
          info: 'on property id'
        )


      it 'calculates the difference between two mappings on the map as a change', ->
        @snippetModel.data
          mappingPropertyOnMap: 'name'
        diff = @choroplethMap.calculateDifference(@oldSnippetModel)
        expect(diff[1].properties[0]).to.eql
          label: 'mapping'
          key: 'mappingPropertyOnMap'
          difference:
            type: 'change'
            previous: 'id'
            after: 'name'


      # NOTE: this is too complicated for now since it requires the difference calculator
      # to know how many different mappings are possible on the data
      # it 'calculates the difference between two mappings on the data as a change'


      # it 'calculates the addition of a mapping on the data as an add diff'


      # it 'calculates the deletion of a a mapping on the data as a delete diff'


    describe 'Data Section', ->

      beforeEach ->
        @reorderedMessyData = []
        @moreMessyData = []
        @lessMessyData = []
        @changedMessyData = []
        @differentMessyData = []
        $.extend(true, @reorderedMessyData, messyData)
        $.extend(true, @moreMessyData, messyData)
        $.extend(true, @lessMessyData, messyData)
        $.extend(true, @changedMessyData, messyData)
        $.extend(true, @differentMessyData, messyData)
        @reorderedMessyData.reverse()
        @moreMessyData.push
          "Some weird col": "more weird values"
          "an id": 4
          "value": "3'333'333.010101010"
        @lessMessyData.splice(messyData.length - 1, 1)
        @changedMessyData[0]['value'] = "42"
        for i in [0..@differentMessyData.length-1]
          @differentMessyData[i].newCol = i


      it 'recognizes two equal data sets', ->
        diff = @choroplethMap.calculateDifference(@oldSnippetModel)
        expect(diff[2].properties.length).to.equal(0)


      it 'does not care about reordering the same rows', ->
        @snippetModel.data
          data: @reorderedMessyData
        diff = @choroplethMap.calculateDifference(@oldSnippetModel)
        expect(diff[2].properties.length).to.equal(0)


      it 'calculates an addition of a row as an add diff', ->
        @snippetModel.data
          data: @moreMessyData
        diff = @choroplethMap.calculateDifference(@oldSnippetModel)
        expect(diff[2].properties[0]).to.eql
          label: ''
          key: 'data'
          difference:
            type: 'add'
            content: "more weird values, 4, 3'333'333.010101010"
            unformattedContent: {'Some weird col': 'more weird values', 'an id': 4, 'value': "3'333'333.010101010"}


      it 'calculates a deletion of a row as a delete diff', ->
        @snippetModel.data
          data: @lessMessyData
        diff = @choroplethMap.calculateDifference(@oldSnippetModel)
        expect(diff[2].properties[0]).to.eql
          label: ''
          key: 'data'
          difference:
            type: 'delete'
            content: "who parses json like this?, 2, 2'222'222.00000002"
            unformattedContent: {'Some weird col': 'who parses json like this?', 'an id': 2, 'value': "2'222'222.00000002"}


      it 'calculates a changed value in a cell as one add diff and one delete diff', ->
        @snippetModel.data
          data: @changedMessyData
        diff = @choroplethMap.calculateDifference(@oldSnippetModel)
        expect(diff[2].properties).to.eql([
          label: ''
          key: 'data'
          difference:
            type: 'add'
            content: "weirdest Value, 3, 42"
            unformattedContent: {'Some weird col': 'weirdest Value', 'an id': 3, 'value': '42'}
        ,
          label: ''
          key: 'data'
          difference:
            type: 'delete'
            content: "weirdest Value, 3, 1'111'111.34"
            unformattedContent: {'Some weird col': 'weirdest Value', 'an id': 3, 'value': "1'111'111.34"}
        ])


      it 'calculates a complete add and delete diff for the whole table when a column is added', ->
        @snippetModel.data
          data: @differentMessyData
        diff = @choroplethMap.calculateDifference(@oldSnippetModel)
        expect(diff[2].properties.length).to.equal(4)


    describe 'Visualization Section', ->

      it 'recognizes an unchanged value property', ->
        diff = @choroplethMap.calculateDifference(@oldSnippetModel)
        expect(diff[3].properties[0]).to.eql
          label: 'value property'
          key: 'valueProperty'
          difference: undefined
          info: '(value)'


      # maybe at some point we want to indicate the diff between numerical and categorical values
      it 'calculates the difference between two value properties as a change', ->
        @snippetModel.data
          valueProperty: 'an id'
        diff = @choroplethMap.calculateDifference(@oldSnippetModel)
        expect(diff[3].properties[0]).to.eql
          label: 'value property'
          key: 'valueProperty'
          difference:
            type: 'change'
            previous: 'value'
            after: 'an id'


      it 'recognizes an unchanged color scheme', ->
        diff = @choroplethMap.calculateDifference(@oldSnippetModel)
        expect(diff[3].properties[1]).to.eql
          label: 'color scheme'
          key: 'colorScheme'
          difference: undefined
          info: '(YlGn)'


      it 'calculates the difference between two color schemes as a change', ->
        @snippetModel.data
          colorScheme: 'Set1'
        diff = @choroplethMap.calculateDifference(@oldSnippetModel)
        expect(diff[3].properties[1]).to.eql
          label: 'color scheme'
          key: 'colorScheme'
          difference:
            type: 'change'
            previous: 'YlGn'
            after: 'Set1'


      it 'recognizes an unchanged number of color steps', ->
        diff = @choroplethMap.calculateDifference(@oldSnippetModel)
        expect(diff[3].properties[2]).to.eql
          label: 'quantize steps'
          key: 'quantizeSteps'
          difference: undefined
          info: '(3)'


      it 'calculates the difference between two color steps as a change', ->
        @snippetModel.data
          quantizeSteps: 4
        diff = @choroplethMap.calculateDifference(@oldSnippetModel)
        expect(diff[3].properties[2]).to.eql
          label: 'quantize steps'
          key: 'quantizeSteps'
          difference:
            type: 'change'
            previous: 3
            after: 4


  describe 'Geojson properties for mapping', ->

    beforeEach ->
      @expectedForMapping = biggerSampleMap.features.map (feature) -> {id: feature.properties['id']}
      @expectedMissingForMapping = ['name']


    it 'should get the properties allowed for mapping', ->
      { propertiesForMapping, propertiesWithMissingEntries } = @choroplethMap.getPropertiesForMapping()
      expect(propertiesForMapping).to.eql(@expectedForMapping)


    it 'should get the properties with missing entries for mapping', ->
      { propertiesForMapping, propertiesWithMissingEntries } = @choroplethMap.getPropertiesForMapping()
      expect(propertiesWithMissingEntries).to.eql(@expectedMissingForMapping)


  describe 'CSV columns for mapping', ->

    beforeEach ->
      @snippetModel.data
        mappingPropertyOnMap: 'id'


    it 'gets one data property that can be mapped on messy data and bigger sample map', ->
      properties = @choroplethMap.getDataPropertiesForMapping()
      expect(properties).to.eql(['an id'])


    it 'gets two data properties that can be mapped on sample1DData and sammpleMap', ->
      @snippetModel.data
        data: sample1DData
        map: sampleMap

      properties = @choroplethMap.getDataPropertiesForMapping()
      expect(properties).to.eql(['id', 'alternativeId'])


    it 'gets no data properties that can be mapped on switzerlandData and sampleMap', ->
      @snippetModel.data
        data: switzerlandData
        map: sampleMap

      properties = @choroplethMap.getDataPropertiesForMapping()
      expect(properties).to.eql([])


    it 'gets no data properties that can be mappend on switzerlandData and switzerlandMap on mapping NAME_0', ->
      @snippetModel.data
        data: switzerlandData
        map: switzerlandSampleMap
        mappingPropertyOnMap: 'NAME_0'

      properties = @choroplethMap.getDataPropertiesForMapping()
      expect(properties).to.eql([])


    # special since there is only one geometry feature (zurich)
    it 'gets one data property that can be mapped on switzerlandData and zurichSampleMap', ->
      @snippetModel.data
        data: switzerlandData
        map: zurichSampleMap
        mappingPropertyOnMap: 'NAME_1'

      properties = @choroplethMap.getDataPropertiesForMapping()
      expect(properties).to.eql(['Canton'])


  describe 'Sanitizing visualization data', ->

    it 'camelCases all column names', ->
      { sanitizedData, keyMapping } = @choroplethMap.getDataSanitizedForNgGrid()
      expect(sanitizedData[0]).to.eql(
        "SomeWeirdCol": "weirdest Value"
        "AnId": 3
        "Value": "1'111'111.34"
      )


    it 'produces a valid key mapping', ->
      { sanitizedData, keyMapping } = @choroplethMap.getDataSanitizedForNgGrid()
      expect(keyMapping).to.eql(
        "Some weird col": "SomeWeirdCol"
        "an id": "AnId"
        "value": "Value"
      )


  describe 'Value Type', ->

    beforeEach ->
      @snippetModel.data
        data: valueTypeSamples

    it 'determines a number correctly', ->
      expect(@choroplethMap._determineValueType(5)).to.eql('numerical')


    it 'determines a number as a string correctly', ->
      expect(@choroplethMap._determineValueType('5')).to.eql('numerical')


    it 'determines a category correctly', ->
      expect(@choroplethMap._determineValueType('Democrats')).to.eql('categorical')


    it 'determines undefined correctly', ->
      expect(@choroplethMap._determineValueType(undefined)).to.eql('categorical')


    it 'gets the correct value type for numerical data', ->
      @snippetModel.data
        valueProperty: 'numerical'
      expect(@choroplethMap.getValueType()).to.eql('numerical')


    it 'gets the correct value type for categorical data', ->
      @snippetModel.data
        valueProperty: 'categorical'
      expect(@choroplethMap.getValueType()).to.eql('categorical')


    it 'gets the correct value type for numerical data with noise', ->
      @snippetModel.data
        valueProperty: 'numericalNoisy'
      expect(@choroplethMap.getValueType()).to.eql('numerical')


    it 'gets the correct value type for categorical data with noise', ->
      @snippetModel.data
        valueProperty: 'categoricalNoisy'
      expect(@choroplethMap.getValueType()).to.eql('categorical')


    it 'gets all categories for categorical data', ->
      @snippetModel.data
        valueProperty: 'categorical'
      expect(@choroplethMap.getCategoryValues()).to.eql([
        'Democrat',
        'Republican'
      ])

