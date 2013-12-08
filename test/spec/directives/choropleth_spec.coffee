describe 'choropleth directive', ->

  directiveElem = null
  directiveScope = null

  # Most of the business logic is implemented on the UI Model which pulls the
  # data dynamically from the snippet model. Thus for a lot of tests data has
  # to be set on the snippet model AND the directives scope. This helper makes
  # this easier.
  # The coupling between UI model and directive scope is by design to have better
  # separation of concerns. From an architectural stand-point the snippet model
  # is sort of a data-layer for the app. It might make sense to wrap/abstract
  # this part of the snippet model into a data-layer that is globally accessible,
  # sort of like a database.
  setData = (snippetModel, scope, data) ->
    snippetModel.data(data)
    for key, value of data
      scope[key] = value


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

    @choropleth = new ChoroplethMap(@snippetModel.id)
    { directiveElem, directiveScope } = retrieveDirective(choroplethMapConfig.directive)
    setData @snippetModel, directiveScope,
      data: sample1DData
      mappingPropertyOnMap: 'id'
      mappingPropertyOnData: 'id'
      projection: 'mercator'
      colorScheme: 'Paired'
      colorSteps: 9
      valueProperty: 'value'
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
      # setData @snippetModel, directiveScope,
      #   map: sampleMap
      directiveScope.map = sampleMap
      directiveScope.$digest()
      # NOTE: JQuery does not support the viewBox attribute so we need to use
      # the SVG DOM API here
      viewBox = $('.choropleth')[0].viewBox
      expect(viewBox.baseVal.width).to.eql(467.88330078125)
      expect(viewBox.baseVal.height).to.eql(146.29034423828125)
      expect(viewBox.baseVal.x).to.eql(195.8579864501953)
      expect(viewBox.baseVal.y).to.eql(256.8436584472656)


    it 'should change the viewBox property on the svg when the map changes', ->
      directiveScope.map = sampleMap
      directiveScope.$digest()
      directiveScope.map = smallerSampleMap
      directiveScope.$digest()
      viewBox = $('.choropleth')[0].viewBox
      expect(viewBox.baseVal.width).to.eql(100.67922973632813)
      expect(viewBox.baseVal.height).to.eql(117.65719604492188)
      expect(viewBox.baseVal.x).to.eql(195.88800048828125)
      expect(viewBox.baseVal.y).to.eql(256.83514404296875)


    it 'should lower the height property on dropping into a narrower container', ->
      directiveScope.map = sampleMap
      directiveScope.$digest()
      expect($('.choropleth').height()).to.eql(312)

      # simulate drag&drop
      $('body').find(directiveElem).remove()
      $('#narrowContainer').append(directiveElem)
      directiveScope.lastPositioned = (new Date()).getTime()
      directiveScope.$digest()
      expect($('#narrowContainer .choropleth').height()).to.eql(62)


    it 'should raise the height property on dropping into a wider container', ->
      $('body').find(directiveElem).remove()
      $('#narrowContainer').append(directiveElem)
      directiveScope.map = sampleMap
      directiveScope.$digest()
      expect($('#narrowContainer .choropleth').height()).to.eql(62)

      $('#narrowContainer').find(directiveElem).remove()
      $('#wideContainer').append(directiveElem)
      directiveScope.lastPositioned = (new Date()).getTime()
      directiveScope.$digest()
      expect($('#wideContainer .choropleth').height()).to.eql(250)


  describe 'visualizing data on a map', ->

    beforeEach ->
      directiveScope.map = sampleMap

    it 'renders data points on a map', ->
      directiveScope.data = sample1DData
      directiveScope.$digest()
      paths = directiveElem.find('path')
      expect($(paths[0]).attr('class')).to.eql('q0-9')
      expect($(paths[1]).attr('class')).to.eql('q8-9')


    it 'adds tooltip title for each data point', ->
      directiveScope.data = sample1DData
      directiveScope.$digest()
      paths = directiveElem.find('path')
      expect($(paths[0]).attr('data-title')).to.eql('3')
      expect($(paths[1]).attr('data-title')).to.eql('7')


    it 'adds data-region for each data point mapping', ->
      directiveScope.data = sample1DData
      directiveScope.$digest()
      paths = directiveElem.find('path')
      expect($(paths[0]).attr('data-region')).to.eql('1')
      expect($(paths[1]).attr('data-region')).to.eql('2')


    describe 'removing a data point', ->

      beforeEach ->
        @originalData = [
          id: 1
          value: 1
        ,
          id: 2
          value: 2
        ,
          id: 3
          value: 3
        ]

        directiveScope.data = @originalData
        directiveScope.map = biggerSampleMap
        directiveScope.$digest()

      it 'removes the rendering for a data point on the map', ->
        @originalData.splice(1, 1)
        directiveScope.$digest()
        paths = directiveElem.find('path')
        expect($(paths[0]).attr('class')).to.eql('q0-9')
        expect($(paths[1]).attr('class')).to.be.undefined
        expect($(paths[2]).attr('class')).to.eql('q8-9')


    describe 'for categorical data', ->

      beforeEach ->
        setData @snippetModel, directiveScope,
          data: sampleCategoricalData
          map: biggerSampleMap
          valueProperty: 'party'
          mappingPropertyOnMap: 'id'
          mappingPropertyOnData: 'id'


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
          entries = directiveElem.find('li.key')
          expect(entries.length).to.eql(2) # Republicans and Democrats


        it 'renders the text for each legend entry', ->
          directiveScope.$digest()
          entries = directiveElem.find('li.key')
          expect($(entries[0]).text()).to.eql('Democrats')
          expect($(entries[1]).text()).to.eql('Republicans')


        it 'renders only categories that are shown in the map with different value and mapping', ->
          setData @snippetModel, directiveScope,
            data: switzerlandData
            map: switzerlandSampleMap
            valueProperty: 'gov'
            mappingPropertyOnMap: 'NAME_1'
            mappingPropertyOnData: 'Canton'
          directiveScope.$digest()
          entries = directiveElem.find('li.key')
          expect(entries.length).to.eql(1)


        it 'renders the correct text for only the category shown in the map', ->
          setData @snippetModel, directiveScope,
            data: switzerlandData
            map: switzerlandSampleMap
            valueProperty: 'gov'
            mappingPropertyOnMap: 'NAME_1'
            mappingPropertyOnData: 'Canton'
          directiveScope.$digest()
          entries = directiveElem.find('li.key')
          expect($(entries[0]).text()).to.eql('CVP')


        it 'renders only categories that are shown in the map with equal value and mapping', ->
          setData @snippetModel, directiveScope,
            data: switzerlandData
            map: switzerlandSampleMap
            valueProperty: 'Canton'
            mappingPropertyOnMap: 'NAME_1'
            mappingPropertyOnData: 'Canton'
          directiveScope.$digest()
          entries = directiveElem.find('li.key')
          expect(entries.length).to.eql(1)


        it 'renders the correct text for categories that are shown in the map with equal value and mapping', ->
          setData @snippetModel, directiveScope,
            data: switzerlandData
            map: switzerlandSampleMap
            valueProperty: 'Canton'
            mappingPropertyOnMap: 'NAME_1'
            mappingPropertyOnData: 'Canton'
          directiveScope.$digest()
          entries = directiveElem.find('li.key')
          expect($(entries[0]).text()).to.eql('Aargau')


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
        expect(@choropleth.dataPointsWithMissingRegion).to.eql([{ key: '33', value: 20 }])


    describe 'legend rendering', ->

      beforeEach ->
        directiveScope.data = sample1DData
        directiveScope.$digest()

      it 'renders a legend rect for each entry of a numerical data set', ->
        entries = directiveElem.find('li.key')
        expect(entries.length).to.eql(9)


      it 'renders a different number of legend rects when changing the color steps', ->
        directiveScope.colorSteps = 3
        directiveScope.$digest()
        entries = directiveElem.find('li.key')
        expect(entries.length).to.eql(3)


      it 'renders the extent of each legend entry in the text', ->
        entries = directiveElem.find('li.key')
        expect($(entries[0]).text()).to.eql('3 – 3.4')
        expect($(entries[1]).text()).to.eql('3.4 – 3.9')
        expect($(entries[2]).text()).to.eql('3.9 – 4.3') # don't test the middle
        expect($(entries[7]).text()).to.eql('6.1 – 6.6')
        expect($(entries[8]).text()).to.eql('6.6 – 7')


      it 'changes the extent of each legend entry when changing the color steps', ->
        directiveScope.colorSteps = 4
        directiveScope.$digest()
        entries = directiveElem.find('li.key')
        expect($(entries[0]).text()).to.eql('3 – 4')
        expect($(entries[3]).text()).to.eql('6 – 7')


    describe ' and changing the data properties', ->

      beforeEach ->
        directiveScope.data = sample1DData
        directiveScope.mappingPropertyOnMap = 'id'
        directiveScope.mappingPropertyOnData = 'id'

      it 'renders the same data points when selecting the mapping properties', ->
        directiveScope.$digest()
        paths = directiveElem.find('path')
        expect($(paths[0]).attr('class')).to.eql('q0-9')
        expect($(paths[1]).attr('class')).to.eql('q8-9')


      it 'renders the same data points when selecting the value property', ->
        directiveScope.valueProperty = 'value'
        directiveScope.$digest()
        paths = directiveElem.find('path')
        expect($(paths[0]).attr('class')).to.eql('q0-9')
        expect($(paths[1]).attr('class')).to.eql('q8-9')


      it 'renders different data points when selecting different mapping properties', ->
        directiveScope.$digest()
        # changed mapping
        directiveScope.mappingPropertyOnMap = 'reverseMapping'
        directiveScope.mappingPropertyOnData = 'reverseId'
        directiveScope.$digest()
        paths = directiveElem.find('path')
        expect($(paths[0]).attr('class')).to.eql('q8-9')
        expect($(paths[1]).attr('class')).to.eql('q0-9')


      it 'renders different data points when selecting a different value property', ->
        directiveScope.$digest()
        # changed value
        directiveScope.valueProperty = 'alternativeValue'
        directiveScope.$digest()
        paths = directiveElem.find('path')
        expect($(paths[0]).attr('class')).to.eql('q0-9')
        expect($(paths[1]).attr('class')).to.eql('q8-9')


      it 'renders different tooltip titles when selecting a different value property', ->
        directiveScope.$digest()
        directiveScope.valueProperty = 'alternativeValue'
        directiveScope.$digest()
        paths = directiveElem.find('path')
        expect($(paths[0]).attr('data-title')).to.eql('4')
        expect($(paths[1]).attr('data-title')).to.eql('5')


    describe ' and changing the visual properties', ->

      beforeEach ->
        directiveScope.data = sample1DData
        directiveScope.mappingPropertyOnMap = 'id'
        directiveScope.mappingPropertyOnData = 'id'

      it 'assigns different classes when increasing the number of color steps', ->
        directiveScope.colorSteps = 12
        directiveScope.$digest()
        paths = directiveElem.find('path')
        expect($(paths[0]).attr('class')).to.eql('q0-12')
        expect($(paths[1]).attr('class')).to.eql('q11-12')


      it 'assigns different classes when decreasing the number of color steps', ->
        directiveScope.colorSteps = 5
        directiveScope.$digest()
        paths = directiveElem.find('path')
        expect($(paths[0]).attr('class')).to.eql('q0-5')
        expect($(paths[1]).attr('class')).to.eql('q4-5')


      it 'assigns different classes when changing the color scheme', ->
        directiveScope.colorScheme = 'YlGn'
        directiveScope.$digest()
        expect($(directiveElem).attr('class')).to.eql('YlGn')


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



