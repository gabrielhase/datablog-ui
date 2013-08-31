angular.module('ldEditor').controller 'PopoverController',
class PopoverController

  constructor: (@$scope, @uiStateService) ->
    @$scope.close = ($event, target) => @close($event, target)


  close: ($event, target) ->
    $event.stopPropagation()
    @$scope.openCondition.active = false
