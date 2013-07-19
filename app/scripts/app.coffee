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

# global variables
@upfront = @upfront || {}

upfront.variables = do () ->
  apiDomain: 'thelivingdoc.com'
  frontendDomain: ''
  spaceId: 3    # NOTE: spaceId and documentId are only temporary here. The watson CMS should provide these.
  documentId: 9 # The id's are for our staging server (thelivingdoc.com)
