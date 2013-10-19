do ->

  @choroplethMapConfig =

    template: """
      <div ng-controller="ChoroplethMapController">
        <choropleth map="map"
                    last-positioned="lastPositioned"
                    projection="projection"
                    data="data"
                    map-mapping-property="mapMappingProperty"
                    ddata-mapping-property="dataMappingProperty"
                    ddata-value-property="dataValueProperty">
        </choropleth>
      </div>
    """

    directive: """
      <choropleth map="map"
                  last-positioned="lastPositioned"
                  projection="projection"
                  data="data"
                  map-mapping-property="mapMappingProperty"
                  ddata-mapping-property="dataMappingProperty"
                  ddata-value-property="dataValueProperty">
      </choropleth>
    """

    prefilledMaps: [
      {
        name: 'livingmaps.unemploymentChoropleth'
        map: 'usCounties'
        data: 'usUnemployment'
        projection: 'albersUsa'
      }
    ]

    availableMaps: [
      name: 'Austria'
      map: 'austriaBundeslaender'
      projection: 'mercator'
    ,
      name: 'Germany'
      map: 'germanyBundeslaender'
      projection: 'mercator'
    ,
      name: 'Switzerland'
      map: 'switzerlandCantons'
      projection: 'mercator'
    ,
      name: 'US States'
      map: 'usStates'
      projection: 'albersUsa'
    ,
      name: 'US Counties'
      map: 'usCounties'
      projection: 'albersUsa'
    ,
      name: 'World'
      map: 'world'
      projection: 'orthographic'
    ]

    availableProjections: [
      name: 'USA (only US maps)'
      value: 'albersUsa'
    ,
      name: 'Mercator'
      value: 'mercator'
    ,
      name: 'Orthographical'
      value: 'orthographic'
    ,
      name: 'Plate carrée'
      value: 'equirectangular'
    ]
