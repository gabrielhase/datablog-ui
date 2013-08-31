angular
  .module('ldEditor', ['envApi', 'ui.bootstrap.dialog', 'ui.bootstrap.pagination'])
  .config ($httpProvider, $locationProvider) ->
    $locationProvider.html5Mode(true)


  .run ($templateCache, documentService, docService, editorService) ->

    # preload templates
    for templateName, template of angularTemplates
      # put templates in cache by their name
      # flowtextOptions -> flowtext-options.html
      fileName = "#{ doc.words.snakeCase(templateName) }.html"
      $templateCache.put(fileName, template)

    # load document
    documentId = 2 # test document
    documentService.get(documentId).then (document) ->
      editorService.loadDocument(document)

    # setup events after the document is ready
    doc.ready ->
      docService.setup()


# ===============
# global variables
# ===============
@upfront = @upfront || {}
angularTemplates = {}

upfront.variables = do () ->
  apiDomain: 'thelivingdoc.com'
  frontendDomain: ''
  documentId: 2


# ===============
# bootstrap
# ===============
$(document).ready ->
  $root = $(
    """
    <ng-include src="'editor.html'"></ng-include>
    """).appendTo(document.body)
  angular.bootstrap( $root[0], ["ldEditor"] )
