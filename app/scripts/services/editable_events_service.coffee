# NOTE: doc is the public API from livingdocs-engine with which we can access
# the editable.js events.
angular.module('ldEditor').factory 'editableEventsService',
  ($rootScope, uiStateService) ->

    currentSelection = undefined

    # Service
    # -------

    currentTextSelectionPos: {}
    currentSelectionStyles:
      isBold: false
      isItalic: false
      isLinked: false
      link: ''
      isLinkExternal: false
    selectionIsOnInputField: false

    textSelected: (snippet, elem, selection) ->
      if selection
        currentSelection = selection
        @setCurrentSelectionStyles()
        @updateSelectionCoordinates(selection)
        state = {}
        @selectionIsOnInputField = false # de-activate link mode when user selects new text
      else if @selectionIsOnInputField # retain state and currentSelection in link input field (changes selection)
        state = {}
      else
        currentSelection = undefined
        state = false

      $rootScope.$apply(
        uiStateService.set('flowtextPopover', state)
      )


    editLink: ->
      @selectionIsOnInputField = true
      currentSelection.save()


    endLinkEditing: ->
      currentSelection.restore()
      @selectionIsOnInputField = false


    toggleCurrentSelectionBold: ->
      currentSelection.toggleBold()


    toggleCurrentSelectionItalic: ->
      currentSelection.toggleEmphasis()


    # link is either empty -> reset link, or contains the link to be set
    setCurrentSelectionLink: (link, isExternal) ->
      if link && link != ''
        target = "_blank" if isExternal
        currentSelection.link(link, {target: target})
      else
        currentSelection.unlink()


    getCurrentSelectionLink: ->
      links = currentSelection.getTagsByName('a')
      if links.length >= 1
        $(links[0]).attr('href')
      else
        ''


    updateSelectionCoordinates: (selection) ->
      coords = selection.getCoordinates()
      @currentTextSelectionPos.top = coords.top
      @currentTextSelectionPos.left = coords.left
      @currentTextSelectionPos.bottom = coords.bottom
      @currentTextSelectionPos.width = coords.width


    setCurrentSelectionStyles: ->
      @currentSelectionStyles.isBold = @isCurrentSelectionBold()
      @currentSelectionStyles.isItalic = @isCurrentSelectionItalic()
      @currentSelectionStyles.isLinked = @isCurrentSelectionLinked()
      @currentSelectionStyles.link = @getCurrentSelectionLink()


    isCurrentSelectionBold: ->
      @getSelectionState('strong')


    isCurrentSelectionItalic: ->
      @getSelectionState('em')


    isCurrentSelectionLinked: ->
      @getSelectionState('a')


    getSelectionState: (tag) ->
      tags = currentSelection.getTagsByName(tag)
      if tags.length >= 1
        firstTag = tags[0]
        if currentSelection.isExactSelection(firstTag, 'visible')
          true
        else
          false
      else
        false

