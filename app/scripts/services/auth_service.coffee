angular.module('ldEditor').service 'authService',
  ($rootScope, apiHttp, session) ->

    authenticate = ->
      apiHttp
        .post('auth', credentials())
        .success(success)
        .error(error)

    credentials = ->
      email: prompt('Email')
      password: prompt('Password')

    success = (data) ->
      accessToken = data['access_token']
      if accessToken
        session.open(accessToken)
      else
        error()

    error = ->
      alert('Unable to authenticate. Please try again.')
      authenticate()

    $rootScope.$on(session.unauthenticatedEvent, authenticate)

    authenticate: authenticate
