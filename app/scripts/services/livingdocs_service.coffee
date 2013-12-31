angular.module('ldEditor').factory 'livingdocsService',

  ($rootScope, $timeout, editableEventsService, uiStateService, snippetInlineOptionsService, positionService, angularTemplateService, prefillChoroplethService, ngProgress) ->

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
          prefillChoroplethService.prefill(snippet) if prefillChoroplethService.isPrefilledChoropleth(snippet)
          angularTemplateService.insertAngularTemplate(snippet) if angularTemplateService.isAngularTemplate(snippet)


    setupEvents: ->
      doc.textSelection (snippet, elem, selection) =>
        editableEventsService.textSelected(snippet, elem, selection)

      doc.snippetFocused (snippet) ->
        snippetInlineOptionsService.drawEditButton(snippet)
        if snippet.template.identifier == 'livingmaps.choropleth'
          snippetInlineOptionsService.drawHistoryButton(snippet)
        if snippet.template.identifier == 'livingmaps.map'
          snippetInlineOptionsService.drawMapButton(snippet)
        uiStateService.set 'propertiesPanel',
          snippet: snippet

      doc.snippetBlurred (snippet) ->
        snippetInlineOptionsService.removeEditButton()
        if snippet.template.identifier == 'livingmaps.choropleth'
          snippetInlineOptionsService.removeHistoryButton()
        if snippet.template.identifier == 'livingmaps.map'
          snippetInlineOptionsService.removeMapButton()
        currentSelection = undefined # set the current selection in the scope
        uiStateService.deactivatePopovers()
        uiStateService.set 'propertiesPanel',
          active: false
          snippet: undefined

      doc.snippetAdded (snippet) ->
        prefillChoroplethService.prefill(snippet) if prefillChoroplethService.isPrefilledChoropleth(snippet)
        angularTemplateService.insertAngularTemplate(snippet) if angularTemplateService.isAngularTemplate(snippet)

      doc.snippetWasDropped (snippet) ->
        if snippet.identifier == 'livingmaps.choropleth' || prefillChoroplethService.isPrefilledChoropleth(snippet)
          snippet.data
            lastPositioned: (new Date()).getTime()

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
