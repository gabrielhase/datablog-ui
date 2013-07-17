# API component module
angular.module('ldApi', [])

# The actual UI
angular
  .module('ldEditor', ['ldApi'])
  .config([
    '$httpProvider'
    '$locationProvider'
    ($httpProvider, $locationProvider) ->
      $locationProvider.html5Mode(true)
  ])

# global variables
@upfront = @upfront || {}

upfront.variables = do () ->
  apiDomain: 'thelivingdoc.com'
  frontendDomain: ''

