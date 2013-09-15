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
