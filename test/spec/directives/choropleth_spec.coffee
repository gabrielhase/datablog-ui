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


  describe 'visualizing data on a map', ->

    beforeEach ->
      directiveScope.map = sampleMap


    it 'should render data points on a map', ->
      directiveScope.data = sample1DData
      directiveScope.$digest()
      paths = directiveElem.find('path')
      expect($(paths[0]).attr('class')).to.eql('q3-9')
      expect($(paths[1]).attr('class')).to.eql('q8-9')


