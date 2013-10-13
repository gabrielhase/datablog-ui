htmlTemplates.choroplethSidebarForm = """
<div ng-controller="ChoroplethFormController">
  <form class="upfront-form">
    <label>Upload a map (geojson only)</label>
    <input json-upload callback="setMap(data, error)" type="file" name="map"></input>

    <label>Choose a projection</label>
    <select ng-model="selectedProjection" ng-options="option.value as option.name for option in projections">
      <option value="">-- choose Projection --</option>
    </select>
  </form>
</div>
"""
