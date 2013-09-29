angular.module('ldEditor').factory 'livingdocsService',

  ($rootScope, editableEventsService, uiStateService, propertiesPanelService, positionService, angularTemplateService) ->

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

      doc.snippetAdded (snippet) ->
        angularTemplateService.insertAngularTemplate(snippet) if angularTemplateService.isAngularTemplate(snippet)

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

      # NOTE: since we need the renderer to replace directives we need to wait for doc.ready
      doc.ready ->
        doc.document.snippetTree.root.each (snippet) ->
          angularTemplateService.insertAngularTemplate(snippet) if angularTemplateService.isAngularTemplate(snippet)