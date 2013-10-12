angular.module('ldEditor').controller 'ChoroplethFormController',
class ChoroplethFormController

  constructor: (@$scope) ->
    $('#map-upload').change (event) =>
      files = $('#map-upload').prop('files')
      file = files[0]
      reader = new FileReader();
      reader.onload = (aFile) =>
        map = JSON.parse(aFile.target.result)
        @$scope.$apply(
          @$scope.snippet.model.data('map', map)
          @$scope.snippet.model.data('lastChangeTime', (new Date().toJSON()))
        )

      reader.readAsText(file);
