# The session is responsible for managing the access token for an active
# session. Once a session is opened with an access token, it is stored in a
# cookie. Accessing the access token returns a promise, such that code that
# relies on the access token does not need to handle unauthenticated situations.
# If no access token is available, an event is emited and the access token
# promises are queued until a session is opened.
#
# TODO: Use safer storage means than cookies.
class Session
  angular
  .module('ldApi')
  .service('session', ['cookies', '$q', '$rootScope', Session])

  constructor: (@cookies, @$q, @$rootScope) ->

  # The queue of deferreds that need to be resolved once the access token is
  # available.
  openDeferreds: []

  # The name of the unauthenticated event that is broadcasted.
  unauthenticatedEvent: 'session:unauthenticated'

  # The name of the authenticated event that is broadcasted.
  authenticatedEvent: 'session:authenticated'

  # Opens a new session with the given access token. The access token is
  # stored in a cookie and the deferred access token accesses are resolved.
  open: (accessToken) ->
    @cookies.set('accessToken', accessToken)
    @$rootScope.$broadcast(@authenticatedEvent)

    [deferredsToResolve, @openDeferreds] = [@openDeferreds, []]
    for deferred in deferredsToResolve
      deferred.resolve(accessToken)

  close: ->
    @cookies.remove('accessToken')
    @$rootScope.$broadcast(@unauthenticatedEvent)

  # Returns a promise for an access token. When no access token is present, an
  # unauthenticated event is fired. As soon as a new session is opened, the
  # promise gets fullfilled.
  accessToken: ->
    deferred = @$q.defer()
    accessToken = @cookies.get('accessToken')

    if accessToken
      deferred.resolve(accessToken)
    else
      @openDeferreds.push(deferred)
      @$rootScope.$broadcast(@unauthenticatedEvent)

    deferred.promise


