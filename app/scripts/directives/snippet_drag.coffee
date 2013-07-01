angular.module('ldEditor').directive 'snippetDrag', ->

  dragDrop = new doc.DragDrop
    minDistance: 10
    preventDefault: true

  return {
    restrict: 'A'
    link: (scope, element, attrs, SidebarController) ->
      identifier = undefined
      attrs.$observe 'snippetDrag', (snippetIdentifier) ->
        identifier = snippetIdentifier

      $(element).on 'mousedown', (event) ->
        if identifier?
          newSnippet = doc.create(identifier)
          doc.startDrag(snippet: newSnippet, dragDrop: dragDrop)
  }
