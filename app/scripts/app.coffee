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
      for templateName, template of angularTemplates
        # put templates in cache by their name
        # flowtextOptions -> flowtext-options.html
        fileName = "#{ doc.words.snakeCase(templateName) }.html"
        $templateCache.put(fileName, template)

  ])


# ===============
# global variables
# ===============
@upfront = @upfront || {}
angularTemplates = {}

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
      <ng-include src="'editor.html'"></ng-include>
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

