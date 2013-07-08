# This service provides a subset of the interface of $http service. It is
# actually a thin wrapper around $http which simply expands paths to full urls
# using the correct host for the api.
angular.module('ldApi').factory('apiHttp', [
  '$http'
  ($http) ->

    urlWithPath = (path) ->
      [
        "http://api.#{upfront.variables.domain}",
        path.replace(/^\/*/, '')
      ].join('/')

    # Defines a wrapper method around $http for a specific request method that
    # doesn't take data.
    apiNonDataMethod = (method) ->
      (path, config) ->
        $http[method](urlWithPath(path), config)

    # Defines a wrapper method around $http for a specific request method that
    # does take data.
    apiDataMethod = (method) ->
      (path, data, config) ->
        $http[method](urlWithPath(path), data, config)

    get:    apiNonDataMethod('get')
    delete: apiNonDataMethod('delete')
    post:   apiDataMethod('post')
    put:    apiDataMethod('put')
])

