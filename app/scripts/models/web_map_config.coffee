do ->

  @webMapConfig =

    template: """
      <div ng-controller="WebMapController">
        <leaflet center="center" markers="markers" defaults="defaults" tiles="tiles" events="events" id="{{mapId}}">
        </leaflet>
      </div>
    """

    directive: """
      <leaflet center="center" markers="markers" tiles="tiles" events="events">
      </leaflet>
    """

    # properties which will trigger a directive change upon changing their value
    trackedProperties: [
      'center'
      'markers'
      'tiles'
    ]
