# This service provides the exact same interface as the apiHttp service. It is
# actually a thin wrapper around apiHttp which simply adds the promised access
# token obtained from the session service to each request as a url
# parameter.
angular.module('ldApi').factory 'authedHttp', (apiHttp, session) ->

  authedHttp = {}

  wrapMethod = (method) ->
    indexOfConfig = method.length - 1
    ->
      args = Array.prototype.slice.call(arguments)
      config = args[indexOfConfig]

      promise = session.accessToken().then (accessToken) ->
        args[indexOfConfig] = configWithAccessToken(config, accessToken)
        method.apply(@, args)

      httpfyPromise(promise, config)

  for httpMethod, method of apiHttp
    authedHttp[httpMethod] = wrapMethod(method)

  # Appends the access token to the params object inside the config object.
  # Creates the objects if necessary.
  configWithAccessToken = (config={}, accessToken) ->
    config.params ||= {}
    config.params['access_token'] = accessToken
    config

  # Tweaks the promise to accept success and error callbacks. Refer to the
  # angular documentation for further information.
  httpfyPromise = (promise, config) ->
    promise.success = (fn) ->
      httpfyPromise(
        promise.then (response) ->
          fn(response.data, response.status, response.headers, config)
        config
      )
    promise.error = (fn) ->
      httpfyPromise(
        promise.then null, (response) ->
          fn(response.data, response.status, response.headers, config)
        config
      )
    promise

  authedHttp
