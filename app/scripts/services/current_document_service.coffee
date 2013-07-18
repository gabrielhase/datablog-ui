angular.module('ldEditor').factory('currentDocumentService', [
  '$q'
  'authedHttp'
  ($q, authedHttp) ->


    currentDocument = null
    currentDocumentId = null


    reset: () ->
      currentDocument = null


    change: (id) ->
      currentDocument = null
      currentDocumentId = id


    get: () ->
      if currentDocument
        currentDocument
      else
        currentDocumentId = upfront.variables.documentId if !currentDocumentId
        documentPromise = $q.defer()
        # IMPORTANT: the space_id should never change
        apiEndpoint = "spaces/#{upfront.variables.spaceId}/documents/#{currentDocumentId}"
        res = authedHttp.get(apiEndpoint)
        .success (data) ->
          doc = new models.Document
            id: data.document.id
            title: data.document.title
            state: data.document.state
            url: data.document.url
            lastChangedDate: new Date(data.document.updated_at)
          doc
        .then (doc) ->
          currentDocument = doc
          documentPromise.resolve(currentDocument)
          currentDocument

        return documentPromise.promise
])
