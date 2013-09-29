# This file contains several helper functions to make testing angular components
# easier, more descriptive, less verbose, and less error prone.

expect = chai.expect

# Stubs a service by name such that whenever that service is injected, the stub
# is injected instead.
#
# @example
#   mockedHttp = {}
#   stubService('$http', mockedHttp)
stubService = (name, stub) ->
  module ($provide) ->
    $provide.value(name, stub)
    # CoffeeScript's implicit return will cause an error. Returning null
    # circumvents that.
    null

# Retrieves a service by name.
#
# @example
#   $http = retrieveService('$http')
retrieveService = (name) ->
  service = null
  inject [name, (injectedService) -> service = injectedService]
  service

# Retrieve a filter by name.
#
# @example
#   retrieveFilter('uppercase')('foo') # => 'FOO'
retrieveFilter = (name) ->
  filter = null
  inject ($filter) -> filter = $filter(name)
  filter

# Instantiates an angular controller. The dependencies can be specified by an
# object where the key is the name of the service to inject and the value
# is the object to be injected in lieu of that service.
#
# @example
#   angular.module('app').controller('SomeController', ($http, $scope) -> ...)
#   instantiateController('SomeController', $http: mockedHttp, $scope: scope)
instantiateController = (name, injections) ->
  retrieveService('$controller')(name, injections)
