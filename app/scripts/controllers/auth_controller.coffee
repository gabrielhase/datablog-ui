class AuthController


  constructor: (@$scope, @apiHttp, @session) ->
    @$scope.$on(@session.unauthenticatedEvent, => @activate())
    @$scope.$on(@session.authenticatedEvent, => @deactivate())
    @$scope.formSubmitted = => @formSubmitted()
    @$scope.loading = false
    @$scope.active = false


  formSubmitted: ->
    @clearErrorMessage()

    if @isFormValid()
      @performRequest(@formData())
    else
      @showInvalidMessage()


  performRequest: (data) ->
    @showLoadingIndicator()
    @apiHttp
      .post('auth', data)
      .success((data, _) => @requestSucceeded(data))
      .error((_, status) => @requestFailed(status))


  requestSucceeded: (data) ->
    @hideLoadingIndicator()

    accessToken = data['access_token']
    if accessToken
      @session.open(accessToken)
    else
      @showErrorMessage()


  requestFailed: (status) ->
    @hideLoadingIndicator()

    if status == 422
      @showInvalidMessage()
    else
      @showErrorMessage()


  showInvalidMessage: ->
    @$scope.statusMessage = 'Invalid email or password.'


  showErrorMessage: ->
    @$scope.statusMessage = 'An error occured, please try again.'


  clearErrorMessage: ->
    delete @$scope.statusMessage


  activate: ->
    @$scope.active = true


  deactivate: ->
    @$scope.active = false
    @clearFormPassword()
    @clearErrorMessage()


  isActive: ->
    @$scope.active


  isFormValid: ->
    @$scope.form.$valid


  showLoadingIndicator: ->
    @$scope.loading = true


  hideLoadingIndicator: ->
    @$scope.loading = false


  formData: ->
    email: @$scope.email
    password: @$scope.password


  clearFormPassword: ->
    delete @$scope.password


angular.module('ldEditor').controller(
  'AuthController'
  [
    '$scope'
    'apiHttp'
    'session'
    AuthController
  ]
)
