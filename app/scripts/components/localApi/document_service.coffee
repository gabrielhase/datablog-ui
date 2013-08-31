angular.module('ldLocalApi').factory 'documentService', ($q) ->

  docs = {}

  # Service
  # -------

  get: (id) ->
    documentPromise = $q.defer()

    docs[id] ||= new Document
      id: id
      title: 'Test Story'
      revisionNumber: 1
      updatedAt: new Date()
      data:
        "content": [
          {
           "identifier": "bootstrap.column"
           "containers":
             "default": [
               "identifier": "bootstrap.hero"
               "editables": {}
             ]
          }
        ]
        "meta": {}


    documentPromise.resolve(docs[id])
    documentPromise.promise


  save: (document) ->
    deferred = $q.defer()
    document.revisionNumber = document.revision + 1
    deferred.resolve(document)

    deferred.promise


  publish: (document) ->
    @save(document)
