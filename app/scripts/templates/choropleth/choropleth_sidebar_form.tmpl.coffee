htmlTemplates.choroplethSidebarForm = """
<div ng-controller="ChoroplethFormController">
  <form class="upfront-form">
    <fieldset>
      <legend>Map Properties</legend>

      <label>Select a Map from our collection</label>
      <select ng-model="selectedMap" ng-options="option as option.name for option in predefinedMaps">
        <option value="">-- choose Map --</option>
      </select>

      <label>Upload your own map (geojson files only)</label>
      <input json-upload callback="setMap(data, error)" type="file" name="map"></input>

      <label>Choose a projection for the map</label>
      <select ng-model="selectedProjection" ng-options="option.value as option.name for option in projections">
        <option value="">-- choose Projection --</option>
      </select>

    </fieldset>

  </form>
</div>
"""
