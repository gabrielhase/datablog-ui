describe 'angularTemplateService', ->

  service = null

  beforeEach ->
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
          snippetViews:
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


  describe 'loading dependencies', ->

    beforeEach ->
      @yepnope = sinon.stub(window, 'yepnope', (arr) ->
        # call complete directly
        arr[0].complete()
      )
      @$depNode = $("<div data-dependency='Test' data-dependency-resources='TestResUrl'></div>")
      @$nonDepNode = $("<div></div>")


    afterEach ->
      @yepnope.restore()


    it 'loads dependencies for a template', (done) ->
      service.loadTemplate(@$depNode, done)
      expect(@yepnope).to.have.been.calledOnce
      expect(callback).to.have.been.calledOnce


    it "doesn't call yepnope when no dependencies given", ->
      window.Test = {}
      callback = sinon.spy()
      service.loadTemplate(@$nonDepNode, callback)
      expect(@yepnope).not.to.have.been.called
      expect(callback).to.have.been.calledOnce


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
        <div ng-controller="WebMapController" class="ng-scope">
          <div class="angular-leaflet-map ng-isolate-scope" center="center" geojson="geojson"></div>
        </div>
      """)


  describe 'inserting a choropleth', ->
    beforeEach ->
      @mapMediatorService = retrieveService('mapMediatorService')
      @snippetModel =
        id: 'testChoropleth'
        storedData:
          map: 'aMap'
        data: (type) ->
          if type == 'map'
            @storedData.map

      @$directiveRoot = $('<div></div>')


    it 'inserts a d3-choropleth snippet', ->
      service.insertTemplateInstance @snippetModel, @$directiveRoot, new ChoroplethMap(@snippetModel.id)
      controller = @$directiveRoot.find('div').attr('ng-controller')
      cssClass = @$directiveRoot.find('div').attr('class')
      expect(controller).to.eql('ChoroplethMapController')
      expect(cssClass).to.eql('ng-scope')
