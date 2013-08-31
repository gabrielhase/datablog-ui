angular.module('ldEditor').directive 'documentClick', ($document, docService) ->

  (scope, element, attrs) ->

    $document.on "click.livingdocs", (event) ->
      if event.livingdocs?.action != 'imageClick'
        scope.$apply(
          docService.imageClickCleanup.fire()
        )
      scope.$apply(
        docService.click.fire()
      )

    # don't propagate any clicks from within the editor
    $('.-js-editor-root').on "click.livingdocs", (event) ->
      event.stopPropagation()
