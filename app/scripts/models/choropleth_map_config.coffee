do ->

  @choroplethMapConfig =

    template: """
      <div ng-controller="ChoroplethMapController">
        <choropleth data="data" map="map" last-positioned="lastPositioned" projection="projection">
        </choropleth>
      </div>
    """

    directive: """
      <choropleth data="data" map="map" last-positioned="lastPositioned" projection="projection">
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
