angular.module('ldApi').factory 'documentService', ($q, authedHttp) ->

  # Requesting

  getDocument = (id) ->
    authedHttp.get(apiPath(id), cache: true)

  saveDocument = (document) ->
    authedHttp.post(
      apiPath(document.id, 'revisions')
      payloadForSave(document)
    )

  publishDocument = (document) ->
    authedHttp.post(
      apiPath(document.id, 'publication')
      payloadForPublish(document)
    )

  apiPath = (id, suffix) ->
    parts = ['spaces/1/documents', id]
    parts.push(suffix) if suffix
    parts.join('/')

  # Data Handling

  documentDataFromGet = (data) ->
    id: data.document.id
    title: data.document.title
    updatedAt: new Date(data.document.updated_at)
    data: data.document.revision.data
    revisionNumber: data.document.revision.revision_number
    publicationRevisionNumber: data.document.publication?.revision_number

  payloadForSave = (document) ->
    data: document.data
    revision_number: document.revisionNumber

  payloadForPublish = (document) ->
    html: document.html
    slug: prompt('Slug')
    revision_number: document.revisionNumber

  # Deferred Resolving

  instantiateDocumentAndResolve = (deferred, data) ->
    deferred.resolve(
      new Document(documentDataFromGet(data))
    )

  updateDocumentAndResolveAfterSave = (deferred, document, data) ->
    document.revisionNumber = data.revision.revision_number
    deferred.resolve(document)

  updateDocumentAndResolveAfterPublish = (deferred, document, data) ->
    document.publicationRevisionNumber = data.publication.revision_number
    deferred.resolve(document)

  # Deferred Rejecting

  rejectWithLoadError = (deferred, data) ->
    rejectWithCaption(deferred, 'Unable to load the document', data)

  rejectWithSaveError = (deferred, data) ->
    rejectWithCaption(deferred, 'Unable to save the document', data)

  rejectWithPublishError = (deferred, data) ->
    rejectWithCaption(deferred, 'Unable to publish the document', data)

  rejectWithCaption = (deferred, caption, data) ->
    deferred.reject("#{caption}: #{data.error_descriptions[0]}")

  # Public

  get: (id) ->
    deferred = $q.defer()
    getDocument(id)
      .success( (data) -> instantiateDocumentAndResolve(deferred, data) )
      .error( (data) -> rejectWithLoadError(deferred, data) )
    deferred.promise

  save: (document) ->
    deferred = $q.defer()
    saveDocument(document)
      .success(
        (data) -> updateDocumentAndResolveAfterSave(deferred, document, data)
      )
      .error( (data) -> rejectWithSaveError(deferred, data) )
    deferred.promise

  publish: (document) ->
    deferred = $q.defer()
    publishDocument(document)
      .success(
        (data) -> updateDocumentAndResolveAfterPublish(deferred, document, data)
      )
      .error( (data) -> rejectWithPublishError(deferred, data) )
    deferred.promise
