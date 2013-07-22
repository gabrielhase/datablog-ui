class Document

  constructor: ({ @id, @title, @state, @url, @lastChangedDate }) ->
    # empty


  # css class used in view for the state
  statusCssClass: () ->
    @state
