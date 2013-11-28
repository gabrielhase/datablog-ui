angular
  .module('ldEditor', ['envApi', 'ui.bootstrap.modal', 'leaflet-directive', 'ngProgress', 'uiSlider', 'ngGrid'])
  .config ($httpProvider, $locationProvider) ->
    $locationProvider.html5Mode(true)


  .run ($templateCache, documentService, livingdocsService, editorService) ->

    # preload templates
    for templateName, template of htmlTemplates
      # put templates in cache by their name
      # flowtextOptions -> flowtext-options.html
      fileName = "#{ livingmapsWords.snakeCase(templateName) }.html"
      $templateCache.put(fileName, template)

    # load document
    documentId = 15 # test document
    documentService.get(documentId).then (document) ->
      editorService.loadDocument(document)

    # setup events after the document is ready
    doc.ready ->
      livingdocsService.setup()


# ===============
# global variables
# ===============
@upfront = @upfront || {}
htmlTemplates = {}

upfront.variables = do () ->
  apiDomain: 'thelivingdoc.com'
  frontendDomain: ''
  documentId: 15


# ===============
# bootstrap
# ===============
$(document).ready ->
  $root = $(
    """
    <ng-include class="bla" src="'editor.html'"></ng-include>
    """).appendTo(document.body)
  angular.bootstrap( $root[0], ["ldEditor"] )
