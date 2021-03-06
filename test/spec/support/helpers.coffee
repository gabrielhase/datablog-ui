# This file contains several helper functions to make testing angular components
# easier, more descriptive, less verbose, and less error prone.

expect = chai.expect

# mockLeaflet = ->
#   return {
#     marker: ->
#       on: ->
#         true
#       getLatLng: ->
#         true
#     AwesomeMarkers:
#       icon: ->
#         'default'
#     Icon:
#       extend: ->
#         true
#     DivIcon: true
#     control:
#       layers: []
#     CRS:
#       EPSG3857: true
#     Map: ->
#       addLayer: ->
#         true
#       setView: ->
#         true
#       on: ->
#         true
#       whenReady: ->
#         true
#       hasLayer: ->
#         true
#       removeLayer: ->
#         true
#     tileLayer: ->
#       return {
#         addTo: ->
#           true
#       }
#   }


mockNgProgress = ->
  return {
    start: ->
      true
    complete: ->
      true
    status: ->
      true
  }

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

# Retrieve a directive and its scope given its markup.
# Compiles the directive and makes sure the scope is up-to-date
# @example
#   retrieveDirective('<choropleth></choropleth>') # => compiled choropleth directive and the directives scope
retrieveDirective = (markup) ->
  directiveElem = angular.element(markup)
  directiveScope = null
  inject ($rootScope, $compile) ->
    $compile(directiveElem)($rootScope)
    directiveScope = $rootScope
    $rootScope.$digest()
  return { directiveElem, directiveScope }


# Instantiates an angular controller. The dependencies can be specified by an
# object where the key is the name of the service to inject and the value
# is the object to be injected in lieu of that service.
#
# @example
#   angular.module('app').controller('SomeController', ($http, $scope) -> ...)
#   instantiateController('SomeController', $http: mockedHttp, $scope: scope)
instantiateController = (name, injections) ->
  retrieveService('$controller')(name, injections)
