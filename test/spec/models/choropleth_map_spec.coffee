describe 'ChoroplethMap', ->

  beforeEach ->
    @choroplethMap = new ChoroplethMap()


  describe 'Geojson properties for mapping', ->

    beforeEach ->
      @snippetModel =
        data: (key) ->
          if key == 'map'
            biggerSampleMap
      @expectedForMapping = biggerSampleMap.features.map (feature) -> {id: feature.properties['id']}
      @expectedMissingForMapping = ['name']


    it 'should get the properties allowed for mapping', ->
      { propertiesForMapping, propertiesWithMissingEntries } = @choroplethMap.getPropertiesForMapping(@snippetModel)
      expect(propertiesForMapping).to.eql(@expectedForMapping)


    it 'should get the properties with missing entries for mapping', ->
      { propertiesForMapping, propertiesWithMissingEntries } = @choroplethMap.getPropertiesForMapping(@snippetModel)
      expect(propertiesWithMissingEntries).to.eql(@expectedMissingForMapping)
