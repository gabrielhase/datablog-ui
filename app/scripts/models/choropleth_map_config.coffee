do ->

  @choroplethMapConfig =

    template: """
      <div ng-controller="ChoroplethMapController">
        <choropleth map-id="mapId"
                    map="map"
                    last-positioned="lastPositioned"
                    projection="projection"
                    data="data"
                    mapping-property-on-map="mappingPropertyOnMap"
                    mapping-property-on-data="mappingPropertyOnData"
                    value-property="valueProperty"
                    color-steps="colorSteps"
                    color-scheme="colorScheme">
        </choropleth>
      </div>
    """

    directive: """
      <choropleth map-id="mapId"
                  map="map"
                  last-positioned="lastPositioned"
                  projection="projection"
                  data="data"
                  mapping-property-on-map="mappingPropertyOnMap"
                  mapping-property-on-data="mappingPropertyOnData"
                  value-property="valueProperty"
                  color-steps="colorSteps"
                  color-scheme="colorScheme">
      </choropleth>
    """

    # properties which will trigger a directive change upon changing their value
    trackedProperties: [
      'map',
      'data',
      'lastPositioned',
      'projection',
      'mappingPropertyOnMap',
      'mappingPropertyOnData',
      'valueProperty',
      'colorSteps',
      'colorScheme'
    ]

    dataMappingThreshold: 0.5

    prefilledMaps: [
      {
        name: 'livingmaps.unemploymentChoropleth'
        map: 'usCounties'
        data: 'usUnemployment'
        projection: 'albersUsa'
        mappingPropertyOnMap: 'id'
        mappingPropertyOnData: 'id'
      }
    ]

    kickstartProperties:
      projection: 'robinson'

    availableMaps: [
      name: 'Swiss Population Data Map'
      map: 'switzerlandCantons'
      projection: 'mercator'
      data: 'swissPopulationData'
      mappingPropertyOnMap: 'NAME_1'
      mappingPropertyOnData: 'Canton'
      valueProperty: 'Residents'
    ,
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
    ,
      name: 'van der Grinten'
      value: 'vanDerGrinten'
    ,
      name: 'Robinson'
      value: 'robinson'
    ,
      name: 'Hammer'
      value: 'hammer'
    ,
      name: 'Baker'
      value: 'baker'
    ,
      name: 'Conic Conformal'
      value: 'conicConformal'
    ,
      name: 'Cylindrical Stereographic'
      value: 'cylindricalStereographic'
    ,
      name: 'Eckert'
      value: 'eckert1'
    ,
      name: 'Hill'
      value: 'hill'
    ,
      name: 'Winkel'
      value: 'winkel3'
    ]
