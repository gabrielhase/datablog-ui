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
        lastChanged: new Date()
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


    post: (document) ->
      #todo
