class Document

  constructor: ({ @id, @title, @updated_at, @json, revision, state }) ->
    @setState(state)
    @revision = +revision || 0
    @dirty = false
    @html = ''


  # possible values: 'new', 'published', 'updated'
  setState: (state) ->
    if state == 'new' || state == 'published' || state == 'updated'
      @state = state
    else
      console.log "unsupported document state: #{ state }"


  toJson: ->
    # todo: fetch json from doc.toJson()
    # or figure out where to do this best
    @json


  # css class used in view for the state
  statusCssClass: ->
    # todo: check allowed values
    @state
