class SnippetInsertor

  insertScopes = []
  snippetToInsert = undefined

  selectedSnippet: undefined

  # The SnippetInsertor should define how to react to events on the document
  # with respect to the insert mode state.
  constructor: ({ @uiStateService, @$compile, editorService, docService }) ->
    docService.click.add($.proxy(@deactivateInsertMode, @))
    editorService.snippetTemplateClick.add($.proxy(@selectSnippetTemplate, @))


  selectSnippetTemplate: ($event, snippet) ->
    @uiStateService.set('insertMode',
      snippet: snippet
    )
    $event.stopPropagation()


  insertSnippet: ($event, snippetContainer) ->
    insertedSnippetModel = doc.create(snippetToInsert.identifier)
    snippetContainer.append(insertedSnippetModel)
    @uiStateService.set('insertMode', false)


  renderInsertPoint: (scope, $container, snippetContainer) ->
    insertScope = scope.$new()
    insertScopes.push(insertScope)
    @$compile(angularTemplates.addButton)(insertScope, (button, childScope) =>
      $container.append(button)
      childScope.container = $container
      childScope.insertSnippet = ($event) =>
        @insertSnippet($event, snippetContainer)
    )


  activateInsertMode: (scope, insertParams) ->
    if snippetToInsert != undefined
      @deactivateInsertMode(false)
    snippetToInsert = insertParams.snippet
    # insert point in root
    @renderInsertPoint(scope, doc.document.renderer.$root, doc.document.snippetTree.root)
    # insert points in other snippets
    doc.document.snippetTree.each (snippetModel) =>
      if snippetModel.hasContainers
        snippetView = doc.document.renderer.snippets[snippetModel.id]
        for name, container of snippetView.containers
          @renderInsertPoint(scope, $(container), snippetModel.containers[name])


  deactivateInsertMode: (resetSelectedSnippet = true) ->
    while scope = insertScopes.pop()
      if scope.container
        scope.container.find('.add-button').remove()
      scope.$destroy()
      scope = null
    snippetToInsert = undefined
    if resetSelectedSnippet
      @selectedSnippet = undefined
