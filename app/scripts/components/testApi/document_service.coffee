angular.module('ldTestApi').factory 'documentService', ($q, $timeout, $http) ->

  docs = {}

  # Service
  # -------

  get: (id) ->
    documentPromise = $q.defer()
    docs[id] ||= @getStubbedDocument(id)
    documentPromise.resolve(docs[id])
    documentPromise.promise


  getStubbedDocument: (id) ->
    new Document
      id: id
      title: 'Test Story'
      revisionNumber: 0
      updatedAt: new Date()
      data:
        "content": [
          {
            "identifier": "livingmaps.column"
            "containers":
              "default": [
                "identifier": "livingmaps.title"
              ]
          }
        ]
        "meta": {}


  saveDocument: (document) ->
    document.revisionNumber = document.revisionNumber + 1
    true


  save: (document) ->
    deferred = $q.defer()
    if @saveDocument(document)
      deferred.resolve(document)
    else
      deferred.reject('Save failed: the document is too large for your Browsers localstorage')

    deferred.promise
