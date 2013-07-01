# NOTE: doc is the public API from livingdocs-engine with which we can access
# the editable.js events.
angular.module('ldEditor').factory 'editableEventsService',
  ($rootScope, uiStateService) ->

    currentSelection = undefined
    # NOTE: mocked selection is a test object that is used to test toggling of
    # UI states. This will be replaced when the selection from Editable.JS
    # has the required functionality.
    mockedSelection =
      isBold: false
      isItalic: false
      isLinked: false


    # Service
    # -------

    currentTextSelection: {}

    textSelected: (snippet, elem, selection) ->
      currentSelection = selection # set the current selection in the scope
      if selection
        coords = selection.getCoordinates()
        @currentTextSelection.top = coords.top
        @currentTextSelection.left = coords.left
        @currentTextSelection.bottom = coords.bottom
        @currentTextSelection.width = coords.width
        state = {}
      else
        state = false

      $rootScope.$apply(
        uiStateService.set('flowtextPopover', state)
      )


    toggleCurrentSelectionBold: ->
      log.debug "Calling Editable.JS to make text selection #{currentSelection.text()} bold"
      # => Editable.JS: toggle the complete selection bold or un-bold depending on current state
      mockedSelection.isBold = !mockedSelection.isBold


    toggleCurrentSelectionItalic: ->
      log.debug "Calling Editable.JS to make text selection #{currentSelection.text()} italic"
      # => Editable.JS: toggle the complete selection italic or un-italic depending on current state
      mockedSelection.isItalic = !mockedSelection.isItalic


    # link is either empty -> reset link, or contains the link to be set
    toggleCurrentSelectionLink: (link) ->
      log.debug "Calling Editable.JS to change the link on selection #{currentSelection.text()}"
      if link
        mockedSelection.isLinked = link
      else
        mockedSelection.isLinked = false


    expandCurrentSelectionToWord: ->
      log.debug "Calling Editable.JS to expand the current selection of #{currentSelection.text()} to word boundaries"


    isCurrentSelectionBold: ->
      mockedSelection.isBold


    isCurrentSelectionItalic: ->
      mockedSelection.isItalic


    isCurrentSelectionLinked: ->
      mockedSelection.isLinked
