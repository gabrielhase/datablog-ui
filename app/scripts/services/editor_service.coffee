angular.module('ldEditor').factory 'editorService', ($q) ->

    currentDocument: undefined
    snippetTemplateClick: $.Callbacks()

    documentLoaded: $.Callbacks('once')

    loadDocument: (document) ->
      @currentDocument = document
      doc.init(design: design.livingmaps, json: document.data)
      @documentLoaded.fire()


    getCurrentDocument: ->
      @currentDocument


    updateDocument: ->
      @currentDocument.data = doc.toJson()
      @currentDocument.html = $('.doc-section').html()
