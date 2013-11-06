describe 'Choropleth directive', ->

  directiveElem = null
  directiveScope = null

  # TODO: this might be rewritten as a chai.js extension
  equalPath = (path1, path2, delta) ->
    arr1 = path1.split(',')
    arr2 = path2.split(',')
    # take away beginning and end markers
    arr1[0] = arr1[0].replace('M', '')
    arr2[0] = arr2[0].replace('M', '')
    arr1[arr1.length - 1] = arr1[arr1.length - 1].replace('Z', '')
    arr2[arr2.length - 1] = arr2[arr2.length - 1].replace('Z', '')
    # map values
    xVals1 = arr1.map (entry) -> entry.split('L')[0]
    yVals1 = arr1.map (entry) ->
      val = entry.split('L')[1]
      if val
        val
      else
        '0'
    xVals2 = arr2.map (entry) -> entry.split('L')[0]
    yVals2 = arr2.map (entry) ->
      val = entry.split('L')[1]
      if val
        val
      else
        '0'
    # expect same number of values in both paths
    expect(xVals1.length).to.eql(xVals2.length)
    expect(yVals1.length).to.eql(yVals2.length)
    # compare values for delta
    for xVal1, i in xVals1
      xVal2 = xVals2[i]
      expect(+xVal1).to.be.within(+xVal2-delta, +xVal2+delta)
    for yVal1, i in yVals1
      yVal2 = yVals2[i]
      expect(+yVal1).to.be.within(+yVal1-delta, +yVal2+delta)


  beforeEach ->
    @mapMediatorService = retrieveService('mapMediatorService')
    @snippetModel = doc.create('livingmaps.choropleth')
    doc.document.snippetTree.root.append(@snippetModel)
    @snippetModel.data
      data: sample1DData
    @choropleth = new ChoroplethMap
      id: @snippetModel.id
      mapMediatorService: @mapMediatorService
    { directiveElem, directiveScope } = retrieveDirective(choroplethMapConfig.directive)
    directiveScope.projection = 'albersUsa'
    directiveScope.mapId = @choropleth.id
    @mapMediatorService.set(@snippetModel.id, @snippetModel, @choropleth, directiveScope)


  describe 'rendering a map', ->


    it 'should render an svg container', ->
      svg = directiveElem.find('svg')
      expect(svg.length).to.eql(1)


    it 'should render an svg map', ->
      directiveScope.map = sampleMap
      directiveScope.$digest()
      paths = directiveElem.find('path')
      expect(paths.length).to.eql(2)


  describe 'resizing map', ->

    beforeEach ->
      # NOTE: body has an initial width of 384px, maybe this is due to icon offsets
      $('body').attr('style', 'width: 1000px')
      $('body').append(directiveElem)
      $('body').append('<div id="wideContainer" style="width: 800px"></div>')
      $('body').append('<div id="narrowContainer" style="width: 200px"></div>')


    afterEach ->
      $('body').find(directiveElem).remove()


    it 'should set the viewBox property on the svg', ->
      directiveScope.map = sampleMap
      directiveScope.$digest()
      # NOTE: JQuery does not support the viewBox attribute so we need to use
      # the SVG DOM API here
      viewBox = $('svg')[0].viewBox
      expect(viewBox.baseVal.width).to.eql(467.88330078125)
      expect(viewBox.baseVal.height).to.eql(146.29034423828125)
      expect(viewBox.baseVal.x).to.eql(195.8579864501953)
      expect(viewBox.baseVal.y).to.eql(256.8436584472656)


    it 'should change the viewBox property on the svg when the map changes', ->
      directiveScope.map = sampleMap
      directiveScope.$digest()
      directiveScope.map = smallerSampleMap
      directiveScope.$digest()
      viewBox = $('svg')[0].viewBox
      expect(viewBox.baseVal.width).to.eql(100.67922973632813)
      expect(viewBox.baseVal.height).to.eql(117.65719604492188)
      expect(viewBox.baseVal.x).to.eql(195.88800048828125)
      expect(viewBox.baseVal.y).to.eql(256.83514404296875)


    it 'should lower the height property on dropping into a narrower container', ->
      directiveScope.map = sampleMap
      directiveScope.$digest()
      expect($('svg').height()).to.eql(312)

      # simulate drag&drop
      $('body').find(directiveElem).remove()
      $('#narrowContainer').append(directiveElem)
      directiveScope.lastPositioned = (new Date()).getTime()
      directiveScope.$digest()
      expect($('#narrowContainer svg').height()).to.eql(62)



    it 'should raise the height property on dropping into a wider container', ->
      $('body').find(directiveElem).remove()
      $('#narrowContainer').append(directiveElem)
      directiveScope.map = sampleMap
      directiveScope.$digest()
      expect($('#narrowContainer svg').height()).to.eql(62)

      $('#narrowContainer').find(directiveElem).remove()
      $('#wideContainer').append(directiveElem)
      directiveScope.lastPositioned = (new Date()).getTime()
      directiveScope.$digest()
      expect($('#wideContainer svg').height()).to.eql(250)


  describe 'visualizing data on a map', ->

    beforeEach ->
      directiveScope.map = sampleMap


    it 'renders data points on a map', ->
      directiveScope.data = sample1DData
      directiveScope.$digest()
      paths = directiveElem.find('path')
      expect($(paths[0]).attr('class')).to.eql('q0-9')
      expect($(paths[1]).attr('class')).to.eql('q8-9')


    describe 'for categorical data', ->

      beforeEach ->
        @snippetModel.data
          data: sampleCategoricalData
          map: biggerSampleMap
          valueProperty: 'party'
        directiveScope.map = biggerSampleMap
        directiveScope.data = sampleCategoricalData
        directiveScope.valueProperty = 'party'


      it 'renders categorical data', ->
        directiveScope.$digest()
        paths = directiveElem.find('path')
        expect($(paths[0]).attr('class')).to.eql('q0-2')
        expect($(paths[1]).attr('class')).to.eql('q1-2')
        expect($(paths[2]).attr('class')).to.eql('q0-2')
        expect($(paths[3]).attr('class')).to.eql('q0-2')


      describe 'legend rendering', ->

        it 'renders a legend entry for each category', ->
          directiveScope.$digest()
          rects = directiveElem.find('rect')
          expect(rects.length).to.eql(2) # Republicans and Democrats


    describe 'missing data points for region', ->

      beforeEach ->
        directiveScope.map = biggerSampleMap

      it 'saves missing data points for region on model', ->
        directiveScope.data = sample1DData
        directiveScope.$digest()
        expect(@choropleth.regionsWithMissingDataPoints).to.eql([3, 4])


    describe 'missing region for data points', ->

      it 'saves a missing region for data point on model', ->
        directiveScope.data = sample1DData
        directiveScope.$digest()
        expect(@choropleth.dataPointsWithMissingRegion).to.eql(['33'])


    describe 'legend rendering', ->

      beforeEach ->
        directiveScope.data = sample1DData
        directiveScope.$digest()

      it 'renders a legend rect for each entry of a numerical data set', ->
        rects = directiveElem.find('rect')
        expect(rects.length).to.eql(9)


      it 'renders a different number of legend rects when changing the quantize steps', ->
        directiveScope.quantizeSteps = 3
        directiveScope.$digest()
        rects = directiveElem.find('rect')
        expect(rects.length).to.eql(3)


    describe ' and changing the data properties', ->

      beforeEach ->
        directiveScope.data = sample1DData
        directiveScope.mappingPropertyOnMap = 'id'
        directiveScope.mappingPropertyOnData = 'id'

      it 'should render the same data points when selecting the mapping properties', ->
        directiveScope.$digest()
        paths = directiveElem.find('path')
        expect($(paths[0]).attr('class')).to.eql('q0-9')
        expect($(paths[1]).attr('class')).to.eql('q8-9')


      it 'should render the same data points when selecting the value property', ->
        directiveScope.valueProperty = 'value'
        directiveScope.$digest()
        paths = directiveElem.find('path')
        expect($(paths[0]).attr('class')).to.eql('q0-9')
        expect($(paths[1]).attr('class')).to.eql('q8-9')


      it 'should render different data points when selecting different mapping properties', ->
        directiveScope.$digest()
        # changed mapping
        directiveScope.mappingPropertyOnMap = 'reverseMapping'
        directiveScope.mappingPropertyOnData = 'reverseId'
        directiveScope.$digest()
        paths = directiveElem.find('path')
        expect($(paths[0]).attr('class')).to.eql('q8-9')
        expect($(paths[1]).attr('class')).to.eql('q0-9')


      it 'should render different data points when selecting a different value property', ->
        directiveScope.$digest()
        # changed value
        directiveScope.valueProperty = 'alternativeValue'
        directiveScope.$digest()
        paths = directiveElem.find('path')
        expect($(paths[0]).attr('class')).to.eql('q0-9')
        expect($(paths[1]).attr('class')).to.eql('q8-9')


    describe ' and changing the visual properties', ->

      beforeEach ->
        directiveScope.data = sample1DData
        directiveScope.mappingPropertyOnMap = 'id'
        directiveScope.mappingPropertyOnData = 'id'

      it 'assigns different classes when increasing the number of quantize steps', ->
        directiveScope.quantizeSteps = 12
        directiveScope.$digest()
        paths = directiveElem.find('path')
        expect($(paths[0]).attr('class')).to.eql('q0-12')
        expect($(paths[1]).attr('class')).to.eql('q11-12')


      it 'assigns different classes when decreasing the number of quantize steps', ->
        directiveScope.quantizeSteps = 5
        directiveScope.$digest()
        paths = directiveElem.find('path')
        expect($(paths[0]).attr('class')).to.eql('q0-5')
        expect($(paths[1]).attr('class')).to.eql('q4-5')


      it 'assigns different classes when changing the color scheme', ->
        directiveScope.colorScheme = 'Y1Gn'
        directiveScope.$digest()
        svg = directiveElem.find('svg')
        expect($(svg[0]).attr('class')).to.eql('Y1Gn')


  describe 'changing the projection of a map', ->

    beforeEach ->
      directiveScope.map = zurichSampleMap
      directiveScope.projection = 'mercator'


    it 'should render the map with mercator projection', ->
      directiveScope.$digest()
      pathValues = directiveElem.find('path').attr('d')
      equalPath(pathValues, zurichMercator, 0.0001)


    it 'should re-render the map with orthographical projection', ->
      directiveScope.$digest()
      directiveScope.projection = 'orthographic'
      directiveScope.$digest()
      pathValues = directiveElem.find('path').attr('d')
      equalPath(pathValues, zurichOrthographical, 0.0001)



