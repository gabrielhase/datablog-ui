# The uiStateService service encapsulates the current state of the UI. This can be used
# to store and restore a working space.
# The intended use is to listen for uiStateService.state.<specificState> in all kinds
# of angular listeners or set the state of an element declaratively (<specificState> is always a
# literal).
# Using the set method interface allows to internally apply specific UI
# business logic like toggling interdependent interface elements.
angular.module('ldEditor').factory 'uiStateService', ->

  # state of the UI -> this could be saved in localstorage for example
  state:
    # popovers that are rendered over selected text
    'flowtextPopover':
      active: false
    # popover that is rendered over an image
    'imagePopover':
      active: false
    # sidebar contains document and snippet panel
    'sidebar':
      active: true
      foldedOut: false
    'documentPanel':
      active: false
    'snippetPanel':
      active: false
    'propertiesPanel':
      active: false
    # mode for inserting snippets, affects whole editor
    'insertMode':
      active: false
    isActive: (uiElementState) ->
      @[uiElementState].active != false


  # this collection of setters defines what happens when the UI state changes
  setter: {
    # the flowtext popover should remove any existing blocktext popovers
    flowtextPopover: (value) ->
      unless value
        @state['flowtextPopover'].active = false
      else
        @state['flowtextPopover'] = value
        @state['flowtextPopover'].active = true

    sidebar: (value) ->
      unless value
        @state['sidebar'].active = false
      else
        @state['sidebar'] = value
        @state['sidebar'].active = true

    documentPanel: (value) ->
      unless value
        @state['documentPanel'].active = false
      if value
        @setter.snippetPanel.call(@, false)
        @setter.propertiesPanel.call(@, false)
        @state['documentPanel'] = value
        @state['documentPanel'].active = true

    snippetPanel: (value) ->
      unless value
        @state['snippetPanel'].active = false
      if value
        @setter.documentPanel.call(@, false)
        @setter.propertiesPanel.call(@, false)
        @state['snippetPanel'] = value
        @state['snippetPanel'].active = true

    propertiesPanel: (value) ->
      unless value
        @state['propertiesPanel'].active = false
      if value
        @setter.documentPanel.call(@, false)
        @setter.snippetPanel.call(@, false)
        @state['propertiesPanel'] = value
        @state['propertiesPanel'].active = true

    insertMode: (value) ->
      unless value
        @state['insertMode'].active = false
      else
        @state['insertMode'] = value
        @state['insertMode'].active = true

    imagePopover: (value) ->
      unless value
        @state['imagePopover'].active = false
      else
        @state['imagePopover'] = value
        @state['imagePopover'].active = true
  }


  # The set method is the public interface to the outside world
  # This allows us to keep a simple set interface to the outside and route
  # to more elaborate functions, e.g. changeMode or the link, on the inside
  set: (name, state) ->
    @setter[name].call(@, state)

