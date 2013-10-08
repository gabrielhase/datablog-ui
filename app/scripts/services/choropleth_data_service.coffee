angular.module('ldEditor').service 'choroplethDataService', (dataService) ->

  isPrefilledChoropleth: (snippetModel) ->
    prefilledMapNames = ChoroplethMap.getPrefilledMapNames()
    prefilledMapNames.indexOf(snippetModel.identifier) != -1


  prefill: (snippetModel) ->
    for prefilledMap in ChoroplethMap.getPrefilledMaps()
      if prefilledMap.name == snippetModel.identifier
        dataService.get(prefilledMap.map).then (map) ->
          dataService.get(prefilledMap.data).then (data) ->
            snippetModel.data('map', map)
            snippetModel.data('mapIdentifier', 'usCounties')
            snippetModel.data('data', data)
            snippetModel.data('dataIdentifier', 'usUnemployment')
            snippetModel.data('lastChangeTime', (new Date()).toJSON())
