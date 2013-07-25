angular.module('ldEditor').factory 'editorService',

  ->

    currentDocument: undefined

    loadDocument: (document) ->
      @currentDocument = document
      doc.loadDocument(json: document.json)


    updateDocument: ->
      @currentDocument.json = doc.toJson()
      @currentDocument.html = $('.doc-section').html()
