@angularHelpers = do ->

  injector = null

  inject: (injectableName) ->
    # only get the injector once, it stays constant for the whole lifspan of the app: http://stackoverflow.com/questions/13400687/cant-retrieve-the-injector-from-angular
    injector ||= angular.element('.-js-editor-root').controller().$injector
    injectable = injector.get(injectableName)
