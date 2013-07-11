class EditorController


  constructor: ($scope, $q, authedHttp, $http) ->
    documentPromise = $q.defer()
    apiEndpoint = "documents/current"
    authedHttp.post(apiEndpoint, {url: 'http://watson.thelivingdoc.com/africa-story.draft'})
      .success (doc) ->
        documentPromise.resolve(doc)
        doc
      .error (error) ->
        documentPromise.reject('fail')

    $scope.message = 'Ello, Ello'
    $scope.server = documentPromise.promise


angular.module('ldEditor').controller(
  'EditorController'
  [
    '$scope'
    '$q'
    'authedHttp'
    '$http'
    EditorController
  ]
)
