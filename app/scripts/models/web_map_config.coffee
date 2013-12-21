do ->

  @webMapConfig =

    template: """
      <div ng-controller="WebMapController">
        <leaflet center="center" geojson="geojson">
        </leaflet>
      </div>
    """

    directive: """
      <leaflet center="center" geojson="geojson">
      </leaflet>
    """

    # properties which will trigger a directive change upon changing their value
    trackedProperties: [
      'center'
    ]
