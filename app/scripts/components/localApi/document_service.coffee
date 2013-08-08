angular.module('ldLocalApi').factory 'documentService',

  ($q) ->

    docs = {}

    # Service
    # -------

    get: (id) ->
      documentPromise = $q.defer()

      docs[id] ||= new Document
        id: id
        title: 'Data Story'
        state: 'new'
        revision: 1
        updated_at: new Date()
        json:
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
      document.revision = document.revision + 1
      deferred.resolve(status: 200)

      deferred.promise


    publish: (document) ->
      @save(document)
