angular.module('ldEditor').factory 'pageStateService',

  (storageService, $timeout) ->

    # Private
    # -------

    dirtyState = 'saved' # 'saved', 'dirty', 'saving'
    waitingBeforeSave = undefined
    throttle = 5 # seconds to wait between saves


    # Service
    # -------

    onSave: $.Callbacks()


    dirty: ->
      dirtyState = 'dirty'
      @throttledSave()


    isDirty: ->
      dirtyState != 'saved'


    # @api: private
    afterSave: (response) ->
      if dirtyState == 'saving'
        if response.status == 200
          dirtyState = 'saved'

        @onSave.fire(response)


    # @api: private
    saveNow: ->
      if dirtyState != 'saved'
        dirtyState = 'saving'
        storageService.savePage()
          .then (response) =>
            @afterSave(response)


    # @api: private
    # save page after x seconds (if dirty) of first call
    # can be called as often as you like, it will only save every x seconds at most
    #
    # idea: improve this to a mix between debounce and throttle
    # save quickly (a few seconds) after a bunch of quick edits (typing) just like debounce would,
    # but still save at least every 5 seconds even if the user types continuosly like a maniac
    throttledSave: (seconds = throttle) ->
      return if waitingBeforeSave # just abort if a save is already requested

      waitingBeforeSave = $timeout( =>
        waitingBeforeSave = undefined
        @saveNow()
      , seconds * 1000)
