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
      @leafletTemplateSnippetModel =
        id: 'leafletTestModel'
        template:
          $template: $('<div data-template><div data-is="leaflet-map"><p>fallback placeholder</p></div></div>')
      @choroplethTemplateSnippetModel =
        id: 'choroplethTestModel'
        template:
          $template: $('<div data-template><div data-is="d3-choropleth"><p>fallback placeholder</p></div></div>')
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
            leafletTestModel:
              $html: $('<div data-template><div data-is="leaflet-map"><p>fallback placeholder</p></div></div>')
            choroplethTestModel:
              $html: $('<div data-template><div data-is="d3-choropleth"><p>fallback placeholder</p></div></div>')
            emptyTestModel:
              $html: $('<div data-template><div><p>fallback placeholder</p></div></div>')
            unknownTestModel:
              $html: $('<div data-template><div data-is="funny-map"><p>fallback placeholder</p></div></div>')

      @loadTemplate = sinon.stub(service, 'loadTemplate')


    it 'loads the template for an angular-leaflet map', ->
      service.insertAngularTemplate(@leafletTemplateSnippetModel)
      expect(@loadTemplate).to.have.been.calledOnce


    it 'loads the template for a d3 choropleth map', ->
      service.insertAngularTemplate(@choroplethTemplateSnippetModel)
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
      service.insertTemplateInstance(@snippetModel, @$directiveRoot, new Map)
      expect(@$directiveRoot.html()).to.eq("""
        <div ng-controller="MapController" class="ng-scope">
          <div class="angular-leaflet-map" center="center" geojson="geojson"></div>
        </div>
      """)


    it 'reacts to changes on the maps dataIdentifier', ->
      map = new Map
      service.insertTemplateInstance(@snippetModel, @$directiveRoot, map)
      populateData = sinon.spy(map, 'populateData')
      @snippetModel.storedData.dataIdentifier = 'changedTestData'
      service.templateInstances[@snippetModel.id].scope.$digest() # force the digest from the tests
      expect(populateData).to.have.been.called


  describe 'inserting a choropleth', ->
    beforeEach ->
      @snippetModel =
        id: 'testChoropleth'
        storedData:
          dataIdentifier: 'testChoroplethData'
        data: (type) ->
          if type == 'dataIdentifier'
            @storedData.dataIdentifier

      @$directiveRoot = $('<div></div>')


    it 'inserts a d3-choropleth snippet', ->
      service.insertTemplateInstance(@snippetModel, @$directiveRoot, new ChoroplethMap)
      expect(@$directiveRoot.html()).to.eq("""
        <div ng-controller="ChoroplethController" class="ng-scope">
          <choropleth>
          </choropleth>
        </div>
      """)


    it 'reacts to changes on the choropleths dataIdentifier', ->
      choropleth = new ChoroplethMap
      service.insertTemplateInstance(@snippetModel, @$directiveRoot, choropleth)
      populateData = sinon.spy(choropleth, 'populateData')
      @snippetModel.storedData.dataIdentifier = 'changedTestData'
      service.templateInstances[@snippetModel.id].scope.$digest() # force the digest from the tests
      expect(populateData).to.have.been.called
