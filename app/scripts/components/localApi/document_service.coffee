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
            "identifier": "livingmaps.column"
            "containers":
              "default": [
                "identifier": "livingmaps.unemploymentChoropleth"
                "content": {"title": "US Unemployment"}
              ,
                "identifier": "livingmaps.title"
                "content": {"title": "livingmaps"}
              ]
          },
          {
           "identifier": "livingmaps.mainAndSidebar"
           "containers":
             "main": [
               "identifier": "livingmaps.text"
              ,
               "identifier": "livingmaps.text"
              ,
               "identifier": "livingmaps.text"
             ],
             "sidebar": [
              "identifier": "livingmaps.image"
             ,
              "identifier": "livingmaps.map"
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
