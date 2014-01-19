describe.only 'Web Map', ->
  beforeEach ->
    window.L = mockLeaflet()
    @mapMediatorService = retrieveService('mapMediatorService')
    @snippetModel = doc.create('livingmaps.map')
    doc.document.snippetTree.root.append(@snippetModel)
    @webMap = new WebMap(@snippetModel.id)
    @mapMediatorService.set(@snippetModel.id, @snippetModel, @webMap)

  describe 'initialization', ->

    it 'gets its associated snippet model', ->
      expect(@webMap._getSnippetModel()).to.eql(@snippetModel)


  describe 'Difference calculation', ->
    beforeEach ->
      @oldSnippetModel = $.extend(true, {}, @snippetModel)

    it 'recognizes an unchanged tile layer', ->
      diff = @webMap.calculateDifference(@oldSnippetModel)
      expect(diff[0].properties[0]).to.eql
        label: 'Tile Layer'
        key: 'tiles'
        difference: undefined
        info: '(openstreetmap)'


    it 'calculates the difference between two tile layers', ->
      @snippetModel.data
        tiles: @webMap.getAvailableTileLayers()['opencyclemap']
      diff = @webMap.calculateDifference(@oldSnippetModel)
      expect(diff[0].properties[0]).to.eql
        label: 'Tile Layer'
        key: 'tiles'
        difference:
          type: 'change'
          previous: 'openstreetmap'
          after: 'opencyclemap'


    it 'recognizes an unchanged center', ->
      diff = @webMap.calculateDifference(@oldSnippetModel)
      expect(diff[1].properties[0]).to.eql
        label: 'Center'
        key: 'center'


    it 'calculates the difference between two centers', ->
      @snippetModel.data
        center:
          lat: 1
          lng: 2
          zoom: 12
      diff = @webMap.calculateDifference(@oldSnippetModel)
      expect(diff[1].properties[0]).to.eql
        label: 'Center'
        key: 'center'
        difference: 'blobChange'

    it 'recognizes an unchanged zoom level'

    it 'calculates the difference between two zoom levels'
