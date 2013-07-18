@models ||= {}

class models.SnippetInsertor

  insertScopes = []
  snippetToInsert = undefined

  selectedSnippet: undefined

  # The SnippetInsertor should define how to react to events on the document
  # with respect to the insert mode state.
  constructor: ({@uiStateService, @$compile, docObserverService}) ->
    docObserverService.click.add($.proxy(@deactivateInsertMode, @))
    docObserverService.snippetTemplateClick.add($.proxy(@selectSnippetTemplate, @))


  selectSnippetTemplate: ($event, snippet) ->
    @uiStateService.set('insertMode',
      snippet: snippet
    )
    $event.stopPropagation()


  insertSnippet: ($event, snippetContainer) ->
    snippetContainer.append(doc.create(snippetToInsert.identifier))
    @uiStateService.set('insertMode', false)


  renderInsertPoint: (scope, $container, snippetContainer) ->
    insertScope = scope.$new()
    insertScopes.push(insertScope)
    @$compile(upfront.angularTemplates.addButton)(insertScope, (button, childScope) =>
      $container.append(button)
      childScope.container = $container
      childScope.insertSnippet = ($event) =>
        @insertSnippet($event, snippetContainer)
    )


  activateInsertMode: (scope, insertParams) ->
    if snippetToInsert != undefined
      @deactivateInsertMode(false) # TODO: this is pretty ugly -> we need a different behavior to handle activation and toggle state
    snippetToInsert = insertParams.snippet
    doc.document.snippetTree.each (snippet) =>
      if snippet.hasContainers
        snippetElem = doc.document.renderer.snippets[snippet.id]
        for name, container of snippetElem.containers
          @renderInsertPoint(scope, $(container), snippet.containers[name])



  deactivateInsertMode: (resetSelectedSnippet = true) ->
    while scope = insertScopes.pop()
      if scope.container
        scope.container.find('.add-button').remove()
      scope.$destroy()
      scope = null
    snippetToInsert = undefined
    if resetSelectedSnippet
      @selectedSnippet = undefined
