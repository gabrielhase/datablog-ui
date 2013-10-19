angular.module('ldEditor').controller 'ChoroplethFormController',
class ChoroplethFormController

  constructor: (@$scope, @$http, @ngProgress, @dataService) ->
    @choroplethInstance = @$scope.snippet.model.uiTemplateInstance
    @$scope.setMap = (data, error) => @setMap(data, error)
    @$scope.setData = (data, error) => @setData(data, error)
    @setupProjections()
    @setupPredefinedMaps()
    @initMapPropertySelection()


  initMapPropertySelection: ->
    { propertiesForMapping, propertiesWithMissingEntries } = @choroplethInstance.getPropertiesForMapping(@$scope.snippet.model)
    if propertiesForMapping && propertiesForMapping.length > 0
      @$scope.availableMapProperties = []
      # NOTE: getPropertiesForMapping ensures that the properties are present in
      # all features so it's safe just to take the first
      for key, value of propertiesForMapping[0]
        @$scope.availableMapProperties.push
          label: "#{key} (e.g. #{value})"
          value: key


  setupPredefinedMaps: ->
    @$scope.predefinedMaps = choroplethMapConfig.availableMaps
    @$scope.selectedMap = @$scope.snippet.model.data('dataIdentifier')
    @$scope.$watch('selectedMap', (newVal, oldVal) =>
      if newVal && newVal != oldVal
        @ngProgress.start()
        @dataService.get(newVal.map).then (data) =>
          @ngProgress.complete()
          @$scope.snippet.model.data
            map: data
            dataIdentifier: newVal
            projection: newVal.projection

          @$scope.selectedProjection = newVal.projection
          @initMapPropertySelection()
    )


  setupProjections: ->
    @$scope.projections = choroplethMapConfig.availableProjections
    @$scope.selectedProjection = @$scope.snippet.model.data('projection')
    @$scope.$watch('selectedProjection', (newVal, oldVal) =>
      if newVal && newVal != oldVal
        @$scope.snippet.model.data
          projection: newVal
    )


  setData: (data, error) ->
    if error.message
      alert(error.message)
    else
      @$scope.snippet.model.data
        data: data
      @$scope.availableDataProperties = []
      if data && data.length > 0
        # NOTE: the last entry is more likely not to be a header row
        for key, value of data[data.length - 1]
          @$scope.availableDataProperties.push
            label: "#{key} (e.g. #{value})"
            key: key
            value: value


  setMap: (data, error) ->
    if error.message
      alert(error.message)
    else
      @ngProgress.start()
      promise = @$http.post('http://geojsonlint.com/validate', data)
      promise.error (error) =>
        alert('Could not validate your json with geojsonlint.com. Do you have internet connection?')
        @ngProgress.complete()
      promise.success (response) =>
        if response.status == 'ok'
          @$scope.snippet.model.data
            map: data
          @initMapPropertySelection()
        else
          alert('This is not a geojson file. Sorry currently we only have support for geojson.')
        @ngProgress.complete()
