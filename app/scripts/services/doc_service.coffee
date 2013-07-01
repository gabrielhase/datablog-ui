angular.module('ldEditor').factory 'docService',

  ($rootScope, editableEventsService, uiStateService, propertiesPanelService, positionService) ->

    # Service
    # -------

    click: $.Callbacks()
    imageClickCleanup: $.Callbacks()


    setup: ->
      @setupEvents()


    setupEvents: ->
      doc.textSelection (snippet, elem, selection) =>
        editableEventsService.textSelected(snippet, elem, selection)

      doc.snippetFocused (snippet) ->
        propertiesPanelService.drawEditButton(snippet)
        uiStateService.set 'propertiesPanel',
          snippet: snippet

      doc.snippetBlurred (snippet) ->
        propertiesPanelService.removeEditButton()
        currentSelection = undefined # set the current selection in the scope
        $rootScope.$apply(
          uiStateService.set('propertiesPanel', false)
          uiStateService.set('flowtextPopover', false)
        )

      doc.imageClick (snippet, imagePath, event) ->
        event.livingdocs =
          action: 'imageClick'
        rect = snippet.getBoundingClientRect()
        boundingBox =
          top: positionService.mouse().y
          bottom: positionService.mouse().y
          left: positionService.mouse().x
          width: 0  # mouse pointer is sooooo slim :)
        $rootScope.$apply(
          uiStateService.set('imagePopover',
            boundingBox: boundingBox
            image: snippet
            imagePath: imagePath
          )
        )
