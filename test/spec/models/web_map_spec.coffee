describe 'Web Map', ->
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


  describe 'Merge', ->
    beforeEach ->
      @changedSnippetModel = $.extend(true, {}, @snippetModel)

    it 'merges a tile layer change', ->
      @changedSnippetModel.data
        'tiles': 'other tiles'
      @webMap.merge(@changedSnippetModel)
      expect(@snippetModel.data('tiles')).to.equal('other tiles')


    it 'merges a center change', ->
      @changedSnippetModel.data
        'center': 'other center'
      @webMap.merge(@changedSnippetModel)
      expect(@snippetModel.data('center')).to.equal('other center')


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
      expect(diff[0].properties[1]).to.eql
        label: 'View Box'
        key: 'center'


    it 'calculates the difference between two centers', ->
      @snippetModel.data
        center:
          lat: 1
          lng: 2
          zoom: 3
      diff = @webMap.calculateDifference(@oldSnippetModel)
      expect(diff[0].properties[1]).to.eql
        label: 'View Box'
        key: 'center'
        difference:
          type: 'blobChange'


    describe 'Markers', ->
      beforeEach ->
        @snippetModel.data
          markers: [rocketMarker, shoppingMarker]
        @oldSnippetModel.data
          markers: [rocketMarker, shoppingMarker]


      it 'recognizes an unchanged marker set', ->
        diff = @webMap.calculateDifference(@oldSnippetModel)
        expect(diff[1].properties.length).to.equal(0)


      it 'does not care about the reordering of markers', ->
        @oldSnippetModel.data
          markers: [shoppingMarker, rocketMarker]
        diff = @webMap.calculateDifference(@oldSnippetModel)
        expect(diff[1].properties.length).to.equal(0)


      it 'calculates the addition of a marker as an add diff', ->
        @snippetModel.data
          markers: [rocketMarker, shoppingMarker, coffeeMarker]
        diff = @webMap.calculateDifference(@oldSnippetModel)
        expect(diff[1].properties.length).to.equal(1)
        expect(diff[1].properties[0]).to.eql
          label: ''
          key: 'markers'
          difference:
            type: 'add'
            content: 'icon: coffee, message: coffee'
            unformattedContent: coffeeMarker


      it 'calculates a deletion of a marker as a delete diff', ->
        @snippetModel.data
          markers: [rocketMarker]
        diff = @webMap.calculateDifference(@oldSnippetModel)
        expect(diff[1].properties.length).to.equal(1)
        expect(diff[1].properties[0]).to.eql
          label: ''
          key: 'markers'
          difference:
            type: 'delete'
            content: 'icon: shopping-cart, message: shopping'
            unformattedContent: shoppingMarker


    describe 'Marker Changes', ->
      beforeEach ->
        @modifiedRocketMarker = $.extend(true, {}, rocketMarker)
        @snippetModel.data
          markers: [rocketMarker]
        @oldSnippetModel.data
          markers: [rocketMarker]

      it 'calculates a changed icon in a marker', ->
        @modifiedRocketMarker.icon.options.icon = 'something so wastly different it is unimaginable'
        @oldSnippetModel.data
          markers: [@modifiedRocketMarker]
        diff = @webMap.calculateDifference(@oldSnippetModel)
        expect(diff[1].properties.length).to.equal(1)
        expect(diff[1].properties[0]).to.eql
          label: ''
          key: 'markers'
          difference:
            type: 'change'
            previous: 'icon: something so wastly different it is unimaginable'
            after: 'icon: rocket'


      it 'calculates a changed popover text in a marker'


      it 'calculates a changed marker position'
