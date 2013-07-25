angular.module('ldLocalApi', [])
angular.module('ldLocalApi').factory 'documentService',

  ($q) ->

    docs = {}

    # Service
    # -------

    get: (id) ->
      documentPromise = $q.defer()

      docs[id] ||= new Document
        id: id
        title: 'Watson Story'
        state: 'new'
        revision: 1
        updated_at: new Date()
        json:
          "content": [
            {
              "identifier": "watson.text_layout"
              "containers":
                "default": [
                  "identifier": "watson.title"
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
      deferred.resolve(document)

      deferred.promise
