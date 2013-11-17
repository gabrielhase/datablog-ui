angular.module('ldEditor').factory 'snippetInlineOptionsService',

  ($rootScope, $compile, uiStateService, dialogService) ->

    lastEditBtnScope = undefined
    lastHistoryBtnScope = undefined

    # Service
    # -------

    removeEditButton: ->
      if lastEditBtnScope
        lastEditBtnScope.button.remove()
        lastEditBtnScope.$destroy()


    drawEditButton: (snippet, imagePath) ->
      insertScope = $rootScope.$new()
      lastEditBtnScope = insertScope
      $compile(htmlTemplates.editButton)(insertScope, (button, childScope) ->
        $('body').append(button)
        childScope.button = button
        childScope.buttonStyle =
          position: 'absolute'
          top: snippet.getBoundingClientRect().top + 5
          left: snippet.getBoundingClientRect().left - 40
          fontSize: '2em'
        childScope.snippet = snippet # set the snippet to edit
        childScope.editSnippet = (snippet, $event) ->
          uiStateService.set 'sidebar',
            foldedOut: true
          uiStateService.set 'propertiesPanel',
            snippet: snippet
          $event.stopPropagation()
      )


    removeHistoryButton: ->
      if lastHistoryBtnScope
        lastHistoryBtnScope.button.remove()
        lastHistoryBtnScope.$destroy()


    drawHistoryButton: (snippet) ->
      insertScope = $rootScope.$new()
      lastHistoryBtnScope = insertScope
      $compile(htmlTemplates.historyButton)(insertScope, (button, childScope) ->
        $('body').append(button)
        childScope.button = button
        childScope.buttonStyle =
          position: 'absolute'
          top: snippet.getBoundingClientRect().top + 45
          left: snippet.getBoundingClientRect().left - 37
          fontSize: '2em'
        childScope.snippet = snippet # set the snippet to edit
        childScope.showHistory = (snippet, $event) ->
          dialogService.openHistoryModal(snippet)
          $event.stopPropagation()
      )

