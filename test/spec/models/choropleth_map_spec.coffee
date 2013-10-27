describe 'ChoroplethMap', ->

  beforeEach ->
    module('ldEditor')
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


  describe 'Sanitizing visualization data', ->

    it 'camelCases all column names', ->
      sanitziedData = @choroplethMap.getDataSanitizedForNgGrid()
      expect(sanitziedData[0]).to.eql(
        "SomeWeirdCol": "weirdest Value"
        "AnId": 3
        "Value": "1'111'111.34"
      )



