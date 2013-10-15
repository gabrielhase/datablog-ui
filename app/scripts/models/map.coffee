class Map

  template = """
    <div ng-controller="MapController">
      <leaflet center="center" geojson="geojson">
      </leaflet>
    </div>
  """

  constructor: ({
  }) ->
    # nothing here yet


  getTemplate: ->
    template
