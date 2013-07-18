# The uiStateService service encapsulates the current state of the UI. This can be used
# to store and restore a working space.
# The intended use is to listen for uiStateService.state.<specificState> in all kinds
# of angular listeners and use the provided set method to change the values.
# Using the set method interface allows to internally apply specific UI
# business logic like toggling interdependent interface elements.
angular.module('ldEditor').factory 'uiStateService', () ->


  # state of the UI -> this could be saved in localstorage for example
  state:
    # popovers that are rendered over selected text
    'flowtextPopover': false
    'blocktextPopover': false
    # sidebar contains document and snippet panel
    'sidebar': true
    'documentPanel': false
    'snippetPanel': false
    # mode for inserting snippets, affects whole editor
    'insertMode': false


  # this collection of setters defines what happens when the UI state changes
  setter: {
    # the flowtext popover should remove any existing blocktext popovers
    flowtextPopover: (value) ->
      if value
        @setter.blocktextPopover.call(@, false)
      @state['flowtextPopover'] = value


    # the blocktext popover should remove any existing flowtext popovers
    blocktextPopover: (value) ->
      if value
        @setter.flowtextPopover.call(@, false)
      @state['blocktextPopover'] = value

    sidebar: (value) ->
      @state['sidebar'] = value

    documentPanel: (value) ->
      if value
        @setter.snippetPanel.call(@, false)
      @state['documentPanel'] = value

    snippetPanel: (value) ->
      if value
        @setter.documentPanel.call(@, false)
      @state['snippetPanel'] = value

    insertMode: (value) ->
      @state['insertMode'] = value
  }


  # The set method is the public interface to the outside world
  # This allows us to keep a simple set interface to the outside and route
  # to more elaborate functions, e.g. changeMode or the link, on the inside
  set: (name, visibility) ->
    @setter[name].call(@, visibility)