class EditorController


  constructor: ($scope, $q, authedHttp) ->
    documentPromise = $q.defer()
    console.log "here"
    # IMPORTANT: the space_id should never change
    apiEndpoint = "documents/current"
    authedHttp.post(apiEndpoint, {url: 'http://watson.thelivingdoc.com/africa-story.draft'})
      .success (doc) ->
        console.log "responded"
        documentPromise.resolve(doc)
        doc
      .error (error) ->
        documentPromise.reject('fail')
        console.log "error"

    $scope.message = 'Ello, Ello'
    $scope.server = documentPromise.promise


angular.module('ldEditor').controller(
  'EditorController'
  [
    '$scope'
    '$q'
    'authedHttp'
    EditorController
  ]
)
