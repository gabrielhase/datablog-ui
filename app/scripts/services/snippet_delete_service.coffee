angular.module('ldEditor').factory 'snippetDeleteService',

  ($compile, $rootScope) ->

    # Private
    # -------

    buttonScopes = []

    # Service
    # -------

    renderDeleteButton: (snippet) ->
      snippetElem = doc.document.renderer.snippets[snippet.id]
      snippetElem.$html.find('.upfront-snippet-delete').remove() # ugly hack to clean up saved x's
      buttonScope = $rootScope.$new()
      buttonScopes.push(buttonScope)
      $compile(angularTemplates.deleteButton)(buttonScope, (button, childScope) =>
        childScope.deleteSnippet = => @removeSnippet(snippet)

        if snippetElem.$html.css('position') != 'absolute' && snippetElem.$html.css('position') != 'relative'
          snippetElem.$html.css('position', 'relative')
        snippetElem.$html.prepend(button)
      )


    removeSnippet: (snippet) ->
      @removeDeleteButton(snippet)
      snippet.remove()


    removeDeleteButton: (snippet) ->
      if snippetElem = doc.document.renderer.snippets[snippet.id]
        snippetElem.$html.find('.upfront-snippet-delete').remove()

      while scope = buttonScopes.pop()
        scope.$destroy()
        scope = null
