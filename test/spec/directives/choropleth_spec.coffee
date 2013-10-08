describe 'Choropleth', ->

  directiveElem = null
  directiveScope = null

  beforeEach ->
    choropleth = new ChoroplethMap
    module('ldEditor')
    { directiveElem, directiveScope } = retrieveDirective(choropleth.getTemplate())


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
      expect(viewBox.baseVal.height).to.eql(146.29037475585938)
      expect(viewBox.baseVal.x).to.eql(0)
      expect(viewBox.baseVal.y).to.eql(0)


    it 'should change the viewBox property on the svg when the map changes', ->
      directiveScope.map = sampleMap
      directiveScope.$digest()
      directiveScope.map = smallerSampleMap
      directiveScope.$digest()
      viewBox = $('svg')[0].viewBox
      expect(viewBox.baseVal.width).to.eql(56.938720703125)
      expect(viewBox.baseVal.height).to.eql(91.67935180664063)
      expect(viewBox.baseVal.x).to.eql(0)
      expect(viewBox.baseVal.y).to.eql(0)


    it 'should lower the height property on dropping into a narrower container', ->
      directiveScope.map = sampleMap
      directiveScope.$digest()
      expect($('svg').height()).to.eql(312)

      # simulate drag&drop
      $('body').find(directiveElem).remove()
      $('#narrowContainer').append(directiveElem)
      directiveScope.lastPositioned = (new Date()).toJSON()
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
      directiveScope.lastPositioned = (new Date()).toJSON()
      directiveScope.$digest()
      expect($('#wideContainer svg').height()).to.eql(250)


  describe 'visualizing data on a map', ->

    beforeEach ->
      directiveScope.map = sampleMap


    it 'should render data points on a map', ->
      directiveScope.data = sample1DData
      directiveScope.$digest()
      paths = directiveElem.find('path')
      expect($(paths[0]).attr('class')).to.eql('q3-9')
      expect($(paths[1]).attr('class')).to.eql('q8-9')


