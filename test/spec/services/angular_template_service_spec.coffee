describe 'angularTemplateService', ->

  service = null

  beforeEach ->
    module('ldEditor')
    service = retrieveService('angularTemplateService')


  describe 'recognizing a template indicator', ->

    beforeEach ->
      @templatedSnippetModel =
        template:
          $template: $('<div data-template></div>')
      @snippetModel =
        template:
          $template: $('<div></div>')


    it 'recognizes an angular template', ->
      isAngularTemplate = service.isAngularTemplate(@templatedSnippetModel)
      expect(isAngularTemplate).to.be.true


    it 'ignores a non-template snippet', ->
      isAngularTemplate = service.isAngularTemplate(@snippetModel)
      expect(isAngularTemplate).to.be.false


  describe 'recognizing the correct template type', ->

    beforeEach ->
      @templatedSnippetModel =
        id: 'testModel'
        template:
          $template: $('<div data-template><div data-is="leaflet-map"><p>fallback placeholder</p></div></div>')
      @emptyTemplatedSnippetModel =
        id: 'emptyTestModel'
        template:
          $template: $('<div data-template><div><p>fallback placeholder</p></div></div>')
      @unknownTemplatedSnippetModel =
        id: 'unknownTestModel'
        template:
          $template: $('<div data-template><div data-is="funny-map"><p>fallback placeholder</p></div></div>')

      doc.document =
        renderer:
          snippets:
            testModel:
              $html: $('<div data-template><div data-is="leaflet-map"><p>fallback placeholder</p></div></div>')
            emptyTestModel:
              $html: $('<div data-template><div><p>fallback placeholder</p></div></div>')
            unknownTestModel:
              $html: $('<div data-template><div data-is="funny-map"><p>fallback placeholder</p></div></div>')

      @loadTemplate = sinon.stub(service, 'loadTemplate')


    it 'loads the template for an angular-leaflet map', ->
      service.insertAngularTemplate(@templatedSnippetModel)
      expect(@loadTemplate).to.have.been.calledOnce


    it 'does not load a template when the data-is markup is missing', ->
      service.insertAngularTemplate(@emptyTemplatedSnippetModel)
      expect(@loadTemplate).not.to.have.been.called


    it 'does not load an unkown template markup', ->
      service.insertAngularTemplate(@unknownTemplatedSnippetModel)
      expect(@loadTemplate).not.to.have.been.called


  describe 'inserting a map', ->

    beforeEach ->
      @snippetModel =
        id: 'testMap'
        storedData:
          dataIdentifier: 'testMapData'
        data: (type) ->
          if type == 'dataIdentifier'
            @storedData.dataIdentifier

      @$directiveRoot = $('<div></div>')
      window.L = mockLeaflet()



    it 'inserts a leaflet-map snippet', ->
      service.insertMap(@snippetModel, @$directiveRoot)
      expect(@$directiveRoot.html()).to.eq("""
        <div ng-controller="MapController" class="ng-scope">
          <div class="angular-leaflet-map" center="center" geojson="geojson"></div>
        </div>
      """)


    it 'reacts to changes on the snippets dataIdentifier', ->
      service.insertMap(@snippetModel, @$directiveRoot)
      populateData = sinon.spy(service, 'populateData')
      @snippetModel.storedData.dataIdentifier = 'changedTestData'
      service.mapScopes[@snippetModel.id].$digest() # force the digest from the tests
      expect(populateData).to.have.been.called


  describe 'populating data from snippet model', ->

    beforeEach ->
      @scope = {}
      @snippetModel =
        data: (type) ->
          if type == 'geojson'
            return { someData: 'this would be geojson' }
          if type == 'popupContentProperty'
            return { popupContentProperty: 'name' }


    it 'does populate the scope with the snippet models data', ->
      service.populateData(@snippetModel, @scope)
      expect(@scope.geojson.data).to.eql(@snippetModel.data('geojson'))
      expect(@scope.geojson.popupContentProperty).to.eql(@snippetModel.data('popupContentProperty'))



