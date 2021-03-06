angular.module('ldEditor').service 'prefillChoroplethService', (dataService) ->

  isPrefilledChoropleth: (snippetModel) ->
    prefilledMapNames = choroplethMapConfig.prefilledMaps.map (map) -> map.name #ChoroplethMap.getPrefilledMapNames()
    prefilledMapNames.indexOf(snippetModel.identifier) != -1


  prefill: (snippetModel) ->
    for prefilledMap in choroplethMapConfig.prefilledMaps
      if prefilledMap.name == snippetModel.identifier
        dataService.get(prefilledMap.map).then (map) ->
          dataService.get(prefilledMap.data).then (data) ->
            snippetModel.data
              map: map
              mapName: 'usCounties'
              data: data
              dataIdentifier: 'usUnemployment'
              projection: prefilledMap.projection
              mappingPropertyOnMap: prefilledMap.mappingPropertyOnMap
              mappingPropertyOnData: prefilledMap.mappingPropertyOnData
              valueProperty: prefilledMap.valueProperty
