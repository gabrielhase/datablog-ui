angular.module('ldEditor').factory 'livingdocsService',

  ($rootScope, $timeout, editableEventsService, uiStateService, propertiesPanelService, positionService, angularTemplateService, choroplethDataService, ngProgress) ->

    # Service
    # -------

    click: $.Callbacks()
    imageClickCleanup: $.Callbacks()


    setup: ->
      @loadAngularTemplates()
      @setupEvents()


    loadAngularTemplates: ->
      $timeout ->
        doc.document.snippetTree.root.each (snippet) ->
          choroplethDataService.prefill(snippet) if choroplethDataService.isPrefilledChoropleth(snippet)
          angularTemplateService.insertAngularTemplate(snippet) if angularTemplateService.isAngularTemplate(snippet)


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
        choroplethDataService.prefill(snippet) if choroplethDataService.isPrefilledChoropleth(snippet)
        angularTemplateService.insertAngularTemplate(snippet) if angularTemplateService.isAngularTemplate(snippet)

      doc.snippetWasDropped (snippet) ->
        if snippet.identifier == 'livingmaps.choropleth' || choroplethDataService.isPrefilledChoropleth(snippet)
          #ngProgress.start()
          snippet.data('lastPositioned', (new Date()).toJSON())
          snippet.data('lastChangeTime', (new Date()).toJSON())

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
