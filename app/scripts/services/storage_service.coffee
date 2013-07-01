angular.module('ldEditor').factory 'storageService',
  ($q, editorService, documentService) ->

    savePage: () ->
      savePagePromise = $q.defer()

      editorService.updateDocument()
      document = editorService.currentDocument

      documentService
        .save(document)
        .then(
          (document) -> savePagePromise.resolve(document)
          (reason) -> savePagePromise.reject(reason)
        )

      savePagePromise.promise
