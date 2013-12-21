class Map

  template = """
    <div ng-controller="WebMapController">
      <leaflet center="center" geojson="geojson">
      </leaflet>
    </div>
  """

  constructor: ({
  }) ->
    # nothing here yet


  getTemplate: ->
    template
