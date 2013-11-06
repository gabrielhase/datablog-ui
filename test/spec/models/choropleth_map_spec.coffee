describe 'ChoroplethMap', ->

  beforeEach ->
    @mapMediatorService = retrieveService('mapMediatorService')
    @snippetModel =
      id: 123
      storedData:
        map: biggerSampleMap
        data: messyData
      data: (d) ->
        if typeof d == 'string'
          @storedData[d]
        else
          for key, value of d
            @storedData[key] = value

    @choroplethMap = new ChoroplethMap
      id: @snippetModel.id
      mapMediatorService: @mapMediatorService
    @mapMediatorService.set(@snippetModel.id, @snippetModel, @choroplethMap)


  it 'gets its associated snippet model', ->
    expect(@choroplethMap._getSnippetModel()).to.eql(@snippetModel)


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

