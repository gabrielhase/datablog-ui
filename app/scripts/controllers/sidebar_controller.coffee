angular.module('ldEditor').controller 'SidebarController',
class SidebarController

  constructor: (@$scope, @uiStateService) ->
    @$scope.uiStateService = @uiStateService
    # methods
    @$scope.loadDocument = => @registerActivePanel('documentPanel')
    @$scope.loadSnippets = => @registerActivePanel('snippetPanel')
    @$scope.loadProperties = => @registerActivePanel('propertiesPanel')
    # API for panels
    @hideSidebar = $.proxy(@hide, this)


  registerActivePanel: (panel) ->
    if @uiStateService.state.isActive(panel) # toggle
      if @uiStateService.state.sidebar.foldedOut
        @hide(panel)
      else
        @uiStateService.set 'sidebar',
          foldedOut: true
    else
      @uiStateService.set(panel, {})
      @uiStateService.set 'sidebar',
        foldedOut: true


  hide: (activePanel) ->
    @uiStateService.set 'sidebar',
      foldedOut: false
    @uiStateService.set(activePanel, false)
