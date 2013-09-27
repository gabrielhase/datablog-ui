describe 'angularTemplateService', ->

  service = null
  mockedHttp = {}

  beforeEach ->
    module('ldEditor')
    stubService('$http', mockedHttp)
    service = retrieveService('angularTemplateService')


  describe 'recognizing an angular template', ->

    beforeEach ->
      @templatedSnippetModel =
        template:
          $template: $('<div data-template></div>')


    it 'recognizes an angular template', ->
      isAngularTemplate = service.isAngularTemplate(@templatedSnippetModel)
      expect(isAngularTemplate).to.be.true

