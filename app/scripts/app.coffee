# ===============
# module definitions
# ===============

# local API component module (mock API)
angular.module('ldLocalApi', [])

# API component module
angular.module('ldApi', [])

# The actual UI
angular
  .module('ldEditor', ['ldLocalApi'])
  .config ($httpProvider, $locationProvider) ->
    $locationProvider.html5Mode(true)


  .run ($templateCache, documentService, editableEventsService, editorService) ->

    # preload templates
    for templateName, template of angularTemplates
      # put templates in cache by their name
      # flowtextOptions -> flowtext-options.html
      fileName = "#{ doc.words.snakeCase(templateName) }.html"
      $templateCache.put(fileName, template)

    # load serverDesign from javascript for easier modification
    doc.addDesign(design.bootstrap.snippets, design.bootstrap.config)

    # load document
    documentId = 1
    documentService.get(documentId).then (document) ->
      editorService.loadDocument(document)

    # setup events after the document is ready
    doc.ready ->
      editableEventsService.setup()


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
$(document).ready ->
  $root = $(
    """
    <ng-include src="'editor.html'"></ng-include>
    """).appendTo(document.body)
  angular.bootstrap( $root[0], ["ldEditor"] )
