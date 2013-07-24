class SidebarController

  angular.module('ldEditor').controller 'SidebarController',
    ['$scope', 'uiStateService', SidebarController ]

  constructor: ($scope, uiStateService) ->
    $scope.sidebarHidden = true
    $scope.uiStateService = uiStateService
    # methods
    $scope.loadDocument = => @registerActivePanel($scope, 'documentPanel', uiStateService)
    $scope.loadSnippets = => @registerActivePanel($scope, 'snippetPanel', uiStateService)
    # API for panels
    @hideSidebar = => @hide($scope, uiStateService)


  registerActivePanel: (scope, panel, uiStateService) ->
    if uiStateService.state[panel] # toggle
      @hide(scope, uiStateService)
    else
      uiStateService.set(panel, true)
      scope.sidebarHidden = false


  hide: (scope, uiStateService) ->
    scope.sidebarHidden = true
    uiStateService.set('documentPanel', false)
    uiStateService.set('snippetPanel', false)
