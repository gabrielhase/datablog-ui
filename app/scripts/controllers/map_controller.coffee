angular.module('ldEditor').controller 'MapController',
class MapController

  constructor: (@$scope) ->
    log "created map controller"
    @$scope.testClick = ->
      log "test click", "trace"
      alert('test click')
