angular.module('ldEditor').controller 'ChoroplethFormController',
class ChoroplethFormController

  constructor: (@$scope, @$http, @ngProgress) ->
    @$scope.setMap = (data, error) => @setMap(data, error)
    @setupProjections()


  setupProjections: ->
    @$scope.projections = ChoroplethMap.getProjections()
    @$scope.selectedProjection = @$scope.snippet.model.data('projection')
    @$scope.$watch('selectedProjection', (newVal, oldVal) =>
      if newVal
        @$scope.snippet.model.data('projection', newVal)
        @$scope.snippet.model.data('lastChangeTime', (new Date()).toJSON())
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
          @$scope.snippet.model.data('map', data)
          @$scope.snippet.model.data('lastChangeTime', (new Date()).toJSON())
        else
          alert('This is not a geojson file. Sorry currently we only have support for geojson.')
        @ngProgress.complete()
