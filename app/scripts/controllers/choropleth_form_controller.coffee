angular.module('ldEditor').controller 'ChoroplethFormController',
class ChoroplethFormController

  constructor: (@$scope, @$http, @ngProgress, @dataService) ->
    @$scope.setMap = (data, error) => @setMap(data, error)
    @setupProjections()
    @setupPredefinedMaps()


  setupPredefinedMaps: ->
    @$scope.predefinedMaps = ChoroplethMap.getAvailableMaps()
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
    )


  setupProjections: ->
    @$scope.projections = ChoroplethMap.getProjections()
    @$scope.selectedProjection = @$scope.snippet.model.data('projection')
    @$scope.$watch('selectedProjection', (newVal, oldVal) =>
      if newVal && newVal != oldVal
        @$scope.snippet.model.data
          projection: newVal
    )


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
        else
          alert('This is not a geojson file. Sorry currently we only have support for geojson.')
        @ngProgress.complete()
