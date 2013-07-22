# ===============
# module definitions
# ===============

# API component module
angular.module('ldApi', [])

# The actual UI
angular
  .module('ldEditor', ['ldApi'])
  .config([
    '$httpProvider'
    '$locationProvider'
    ($httpProvider, $locationProvider) ->
      $locationProvider.html5Mode(true)
  ])

  .run([
    '$templateCache'
    ($templateCache) ->

      # preload templates
      templates = upfront.angularTemplates
      for templateName, template of templates
        # put templates in cache by their name
        # flowtextOptions -> flowtext-options.html
        fileName = "#{ doc.words.snakeCase(templateName) }.html"
        $templateCache.put(fileName, template)

  ])


# ===============
# global variables
# ===============
@upfront = @upfront || {}

upfront.variables = do () ->
  apiDomain: 'thelivingdoc.com'
  frontendDomain: ''
  documentId: 1


# ===============
# bootstrap
# ===============
upfront.angular = do ->

  $(document).ready () ->
    upfront.api.post('auth', {})
      .then (data) ->
        upfront.angular.loadDocument(data.accessToken)


  init: ->
    $root = $(
      """
      <div ng-controller='AuthController'>
        <div id='splash' name='form' ng-show='active'>
          <div class='cell'>
            <form name='form' id='auth' ng-submit='formSubmitted()'>
              <h2>Livingdocs</h2>
              <p class='loading' ng-show='loading'>Loading…</p>

              <ng-switch on='loading'>
                <fieldset ng-switch-when='false'>
                  <p ng-show='statusMessage' class="auth-status">{{statusMessage}}</p>
                  <input class="email" name='email' type='email' placeholder='Email' ng-model='$parent.email' autofocus required />
                  <input class="password" name='password' type='password' placeholder='Password' ng-model='$parent.password' required />

                  <input type='submit' id='submit' value='Log In' />
                  <small><a href="#">Forgot your password?</a></small>
                  <small><a href="#">No account? Register here</a></small>
                </fieldset>
              </ng-switch>
            </form>
          </div>
        </div>
        <div class="-js-editor-root upfront-control" ng-controller="EditorController" document-click autosave>
          <div ng-show="serverResponse" class="top-message" ng-animate="{show: 'message-show'}">
            <div ng-show="serverResponse.status == 200">
              page saved
            </div>
            <div ng-show="serverResponse.status != 200">
              There was an error saving your page
            </div>
          </div>

          <div sidebar ng-if="uiStateService.state.sidebar">
            <div document-panel ng-if="uiStateService.state.documentPanel"></div>
            <div snippet-panel ng-if="uiStateService.state.snippetPanel"></div>
          </div>

          <div popover ng-if="uiStateService.state.flowtextPopover" bounding-box="{{ boundingBox }}">
            <ng-include src="'flowtext-options.html'" ng-show="!uiStateService.state.linkPopover">
            </ng-include>
          </div>
        </div>
      </div>
      """).appendTo(document.body)
    angular.bootstrap( $root[0], ["ldEditor"] )


  loadDocument: (accessToken) ->
    upfront.api.get("documents/#{upfront.variables.documentId}", { accessToken: accessToken })
      .then (data) ->
        { document, user, snippetTree } = data
        if document && user && snippetTree
          upfront.__currentUser = user
          upfront.__currentDocument = document

          # load serverDesign from javascript for easier modification
          doc.addDesign(design.watson.snippets, design.watson.config)
          doc.loadDocument(json: snippetTree)

          doc.ready ->
            # load the editor
            upfront.angular.init()

