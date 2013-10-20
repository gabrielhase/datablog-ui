htmlTemplates.choroplethSidebarForm = """
<div class="upfront-sidebar-content-wrapper">
<div class="upfront-sidebar-content" ng-controller="ChoroplethFormController">
  <form class="upfront-form">
    <fieldset>
      <legend>Map Properties</legend>

      <label>Select a Map from our collection</label>
      <select ng-model="mapName" ng-options="option as option.name for option in predefinedMaps">
        <option value="">-- choose Map --</option>
      </select>

      <label>Upload your own map (geojson files only)</label>
      <input json-upload callback="setMap(data, error)" type="file" name="map"></input>

      <label>Choose a projection for the map</label>
      <select ng-model="projection" ng-options="option.value as option.name for option in projections">
        <option value="">-- choose Projection --</option>
      </select>

    </fieldset>
    <fieldset>
      <legend>Data Visualization</legend>

      <label>Select a property that is matched by your data</label>
      <select ng-model="mappingPropertyOnMap" ng-options="option.value as option.label for option in availableMapProperties">
        <option value="">-- choose Property --</option>
      </select>

      <div ng-show="mappingPropertyOnMap">
        <label>Upload a data file (csv only, comma-separated)</label>
        <input csv-upload callback="setData(data, error)" type="file" name="data"></input>

        <label>Select which (numerical) property you want to visualize</label>
        <select ng-model="valueProperty" ng-options="option.key as option.label for option in availableDataProperties">
          <option value="">-- choose Visualization value --</option>
        </select>

        <label>Select a property that matches your selected map property</label>
        <select ng-model="mappingPropertyOnData" ng-options="option.key as option.label for option in availableDataProperties">
          <option value="">-- choose Visualization value --</option>
        </select>

      </div>

    </fieldset

  </form>
</div>
</div>
"""
