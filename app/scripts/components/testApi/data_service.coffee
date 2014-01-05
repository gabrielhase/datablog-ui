angular.module('ldTestApi').factory 'dataService', ($q, $http) ->

  get: (key) ->
    data = $q.defer()
    data.resolve({})
    return data.promise
