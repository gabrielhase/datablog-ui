angular.module('ldEditor').factory 'editorService', ->

    currentDocument: undefined
    snippetTemplateClick: $.Callbacks()


    loadDocument: (document) ->
      @currentDocument = document
      doc.init(design: design.livingmaps, json: document.data)


    updateDocument: ->
      @currentDocument.data = doc.toJson()
      @currentDocument.html = $('.doc-section').html()
