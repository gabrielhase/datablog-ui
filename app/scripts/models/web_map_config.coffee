do ->

  @webMapConfig =

    template: """
      <div ng-controller="WebMapController">
        <leaflet center="center" markers="markers">
        </leaflet>
      </div>
    """

    directive: """
      <leaflet center="center" markers="markers">
      </leaflet>
    """

    # properties which will trigger a directive change upon changing their value
    trackedProperties: [
      'center'
      'markers'
    ]
