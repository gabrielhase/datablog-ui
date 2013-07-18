angular.module('ldEditor').factory('storageService', [
  '$q'
  '$location'
  'authedHttp'
  ($q, $location, authedHttp) ->

    # private
    # -------

    savePagePath = "documents/save"


    # public service
    # --------------

    savePage: () ->
      savePagePromise = $q.defer()

      content = doc.toJson()
      html = $('.doc-section').html() # TODO: this should go into the livingdocs-engine

      # For making cross-origin requests work we set the header to x-www-form-urlencoded, see editor_app.coffee
      # This requires us to serialize JSON ourselves.
      res = authedHttp.post(savePagePath, {url: $location.absUrl(), html: html, snippet_tree: content})
      res.success (data, status) ->
        savePagePromise.resolve({status: status, data: data})
      res.error (data, staus) ->
        savePagePromise.resolve({status: status, data: data})

      savePagePromise.promise
])
