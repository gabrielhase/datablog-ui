angular.module('ldEditor').directive 'documentClick', ($document, livingdocsService) ->

  (scope, element, attrs) ->

    $document.on "click.livingdocs", (event) ->
      if event.livingdocs?.action != 'imageClick'
        scope.$apply(
          livingdocsService.imageClickCleanup.fire()
        )
      scope.$apply(
        livingdocsService.click.fire()
      )

    # don't propagate any clicks from within the editor
    $('.-js-editor-root').on "click.livingdocs", (event) ->
      event.stopPropagation()

    # don't change the selection when clicking on a text format in the popover
    $('.-js-editor-root').on "mousedown.livingdocs", ".flowtext-options", (event) ->
      event.preventDefault()
