class Document

  constructor: ({
    @id
    @title
    @updatedAt
    @data
    @publicationRevisionNumber
    @revisionNumber
  }) ->


  isPublishable: ->
    @publicationRevisionNumber isnt @revisionNumber
