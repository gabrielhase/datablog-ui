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
    @sidebarBecameVisible = $.Callbacks()


  registerActivePanel: (panel) ->
    if @uiStateService.state.isActive(panel) # toggle
      if @uiStateService.state.sidebar.foldedOut
        @uiStateService.blurCurrentSnippet()
        @hide(panel)
      else
        @uiStateService.set 'sidebar',
          foldedOut: true
        @sidebarBecameVisible.fire()
    else
      @uiStateService.blurCurrentSnippet()
      @uiStateService.set(panel, {})
      @uiStateService.set 'sidebar',
        foldedOut: true
      @sidebarBecameVisible.fire()


  hide: (activePanel) ->
    @uiStateService.set 'sidebar',
      foldedOut: false
    @uiStateService.set(activePanel, false)
