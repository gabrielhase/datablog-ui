# NOTE: doc is the public API from livingdocs-engine with which we can access
# the editable.js events.
angular.module('ldEditor').factory  'editableEventsService',

  ($rootScope, $compile, uiStateService, snippetDeleteService) ->

    # Private
    # -------

    currentSelection = undefined
    # NOTE: mocked selection is a test object that is used to test toggling of
    # UI states. This will be replaced when the selection from Editable.JS
    # has the required functionality.
    mockedSelection =
      isBold: false
      isItalic: false
      isLinked: false


    # Service
    # -------

    currentTextSelection: {}

    setup: ->
      @setupEvents()


    textSelected: (snippet, elem, selection) ->
      currentSelection = selection # set the current selection in the scope
      if selection
        coords = selection.getCoordinates()
        @currentTextSelection.top = coords.top
        @currentTextSelection.left = coords.left
        @currentTextSelection.width = coords.width
        visibility = true
      else
        visibility = false

      $rootScope.$apply(
        uiStateService.set('flowtextPopover', visibility)
      )


    setupEvents: ->
      # text selection event
      doc.textSelection (snippet, elem, selection) =>
        @textSelected(snippet, elem, selection)

      doc.snippetFocused (snippet) ->
        if snippet
          snippetDeleteService.renderDeleteButton(snippet)

      doc.snippetBlurred (snippet) ->
        currentSelection = undefined # set the current selection in the scope
        snippetDeleteService.removeDeleteButton(snippet)
        $rootScope.$apply(
          uiStateService.set('flowtextPopover', false)
        )


    toggleCurrentSelectionBold: ->
      console.log("Calling Editable.JS to make text selection #{currentSelection.text()} bold")
      # => Editable.JS: toggle the complete selection bold or un-bold depending on current state
      mockedSelection.isBold = !mockedSelection.isBold


    toggleCurrentSelectionItalic: ->
      console.log("Calling Editable.JS to make text selection #{currentSelection.text()} italic")
      # => Editable.JS: toggle the complete selection italic or un-italic depending on current state
      mockedSelection.isItalic = !mockedSelection.isItalic


    # link is either empty -> reset link, or contains the link to be set
    toggleCurrentSelectionLink: (link) ->
      console.log("Calling Editable.JS to change the link on selection #{currentSelection.text()}")
      if link
        mockedSelection.isLinked = link
      else
        mockedSelection.isLinked = false


    expandCurrentSelectionToWord: ->
      console.log("Calling Editable.JS to expand the current selection of #{currentSelection.text()} to word boundaries")


    # MOCKED FOR NOW -> WILL BE IMPLEMENTED IN LIVINGDOCS-ENGINE

    isCurrentSelectionBold: ->
      mockedSelection.isBold


    isCurrentSelectionItalic: ->
      mockedSelection.isItalic


    isCurrentSelectionLinked: ->
      mockedSelection.isLinked
