angular.module('ldEditor').controller 'PopoverController',
class PopoverController

  constructor: (@$scope, @uiStateService) ->
    @$scope.close = $.proxy(@close, this)


  close: ($event, target) ->
    $event.stopPropagation()
    @$scope.openCondition = false
