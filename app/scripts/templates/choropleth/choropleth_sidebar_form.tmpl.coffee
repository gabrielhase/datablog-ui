htmlTemplates.choroplethSidebarForm = """
<div ng-controller="ChoroplethFormController">
  <form class="upfront-form">
    <label>Upload a map (geojson only)</label>
    <input json-upload callback="setMap(data, error)" type="file" name="map"></input>
  </form>
</div>
"""
