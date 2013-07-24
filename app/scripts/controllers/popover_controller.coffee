class PopoverController

  angular.module('ldEditor').controller 'PopoverController',
    ['$scope', 'uiStateService', PopoverController ]

  constructor: ($scope, uiStateService) ->
    $scope.close = ($event, target) => @close($event, target, uiStateService)


  close: ($event, target, uiStateService) ->
    $event.stopPropagation()
    uiStateService.set('flowtextPopover', false)
