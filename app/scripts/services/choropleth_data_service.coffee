angular.module('ldEditor').service 'choroplethDataService', (dataService, ngProgress) ->

  prefilledChoropleths = ['livingmaps.unemploymentChoropleth']


  isPrefilledChoropleth: (snippetModel) ->
    prefilledChoropleths.indexOf(snippetModel.identifier) != -1


  prefill: (snippetModel) ->
    switch snippetModel.identifier
      when 'livingmaps.unemploymentChoropleth'
        #ngProgress.start()
        dataService.get('usCounties').then (map) ->
          dataService.get('usUnemployment').then (data) ->
            snippetModel.data('map', map)
            snippetModel.data('mapIdentifier', 'usCounties')
            snippetModel.data('data', data)
            snippetModel.data('dataIdentifier', 'usUnemployment')
            snippetModel.data('lastChangeTime', (new Date()).toJSON())
