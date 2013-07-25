angular.module('ldEditor').factory 'storageService',

  ($q, editorService, documentService) ->

    # Private
    # -------

    savePagePath = "documents/save"


    # Service
    # -------

    savePage: () ->
      savePagePromise = $q.defer()

      editorService.updateDocument()
      document = editorService.currentDocument

      # For making cross-origin requests work we set the header to x-www-form-urlencoded, see editor_app.coffee
      # This requires us to serialize JSON ourselves.
      #res = authedHttp.post(savePagePath, {url: $location.absUrl(), html: html, snippet_tree: content})

      documentService.save(document).then (response) ->
        savePagePromise.resolve(status: response.status, data: response.document)

      savePagePromise.promise
