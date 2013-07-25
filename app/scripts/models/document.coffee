class Document

  constructor: ({ @id, @title, @lastChanged, @json, revision, state }) ->
    @setState(state)
    @revision = revision || 0
    @state = 'new'
    @dirty = false


  # possible values: 'new', 'published', 'updated'
  setState: (state) ->
    if state == 'new' || state == 'published' || state == 'updated'
      @state = state
    else
      console.log "unsupported document state: #{ state }"


  # css class used in view for the state
  statusCssClass: () ->
    @state
