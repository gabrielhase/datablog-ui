angular.module('ldEditor').service 'choroplethDataService', (dataService) ->

  isPrefilledChoropleth: (snippetModel) ->
    prefilledMapNames = ChoroplethMap.getPrefilledMapNames()
    prefilledMapNames.indexOf(snippetModel.identifier) != -1


  prefill: (snippetModel) ->
    for prefilledMap in ChoroplethMap.getPrefilledMaps()
      if prefilledMap.name == snippetModel.identifier
        dataService.get(prefilledMap.map).then (map) ->
          dataService.get(prefilledMap.data).then (data) ->
            snippetModel.data
              map: map
              mapIdentifier: 'usCounties'
              data: data
              dataIdentifier: 'usUnemployment'
              projection: prefilledMap.projection
