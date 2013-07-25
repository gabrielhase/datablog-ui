angular.module('ldWatsonApi', [])
angular.module('ldWatsonApi').factory 'documentService',

  ($q, $http) ->

    docs = {}

    # Service
    # -------

    get: (id) ->
      if docs[id]
        docs[id]
      else
        deferred = $q.defer()

        apiEndpoint = "/articles/#{ id }"
        res = $http.get(apiEndpoint).then (response) ->
          data = response.data
          docs[id] = new Document
            id: data.id
            title: data.title
            state: data.state
            revision: data.revision
            updated_at: new Date(data.updated_at)
            json: data.json

          deferred.resolve(docs[id])

        return deferred.promise


    save: (document) ->
      deferred = $q.defer()
      apiEndpoint = "/articles/#{ document.id }"

      payload =
        json: document.toJson()
        revision: document.revision

      res = $http.post(apiEndpoint, payload).then (response) ->
        # todo: manage dirty state (or who should do that?)
        document.revision = response.data.revision
        deferred.resolve(document)

      deferred.promise
