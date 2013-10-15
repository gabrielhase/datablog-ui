class SnippetInsertor

  insertScopes = []
  snippetToInsert = undefined

  selectedSnippet: undefined

  # The SnippetInsertor should define how to react to events on the document
  # with respect to the insert mode state.
  constructor: ({ @uiStateService, @$compile, editorService, livingdocsService }) ->
    livingdocsService.click.add($.proxy(@deactivateInsertMode, @))
    editorService.snippetTemplateClick.add($.proxy(@selectSnippetTemplate, @))


  selectSnippetTemplate: ($event, snippet) ->
    @uiStateService.set('insertMode',
      snippet: snippet
    )
    $event.stopPropagation()


  insertSnippet: ($event, snippetContainer) ->
    insertedSnippetModel = doc.create(snippetToInsert.identifier)
    snippetContainer.append(insertedSnippetModel) # need to call this first to get an instance
    @uiStateService.set('insertMode', false)


  renderInsertPoint: (scope, $container, snippetContainer) ->
    insertScope = scope.$new()
    insertScopes.push(insertScope)
    @$compile(htmlTemplates.addButton)(insertScope, (button, childScope) =>
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
        snippetView = doc.document.renderer.snippetViews[snippetModel.id]
        if snippetView.directives?.container
          for container in snippetView.directives?.container
            @renderInsertPoint(scope, $(container.elem), snippetModel.containers[container.name])


  deactivateInsertMode: (resetSelectedSnippet = true) ->
    while scope = insertScopes.pop()
      if scope.container
        scope.container.find('.add-button').remove()
      scope.$destroy()
      scope = null
    snippetToInsert = undefined
    if resetSelectedSnippet
      @selectedSnippet = undefined
