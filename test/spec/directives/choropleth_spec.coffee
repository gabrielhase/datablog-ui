describe 'Choropleth', ->

  directiveElem = null

  beforeEach ->
    choropleth = new ChoroplethMap
    module('ldEditor')
    directiveElem = retrieveDirective(choropleth.getTemplate())


  it 'should render an svg container', ->
    svg = directiveElem.find('svg')
    expect(svg.length).to.eql(1)
