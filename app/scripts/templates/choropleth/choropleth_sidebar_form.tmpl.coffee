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

      <div ng-show="choroplethInstance.regionsWithMissingDataPoints.length > 0">
        <a class="upfront-btn upfront-btn-mini upfront-btn-danger">{{choroplethInstance.dataPointsWithMissingRegion.length}}</a>
        <small>Regions with no corresponding data values</small>
      </div>

      <div ng-show="mappingPropertyOnMap">
        <label>Upload a data file (csv only, comma-separated)</label>
        <input csv-upload callback="setData(data, error)" type="file" name="data"></input>
        <div ng-show="snippet.model.data('data')">
          Your Data File:
          <a class="upfront-btn upfront-btn-mini upfront-btn-success"
              ng-click="openDataModal(choroplethInstance.dataPointsWithMissingRegion)">
            {{snippet.model.data('data').length}} rows
          </a>
        </div>

        <label>Select which (numerical) property you want to visualize</label>
        <select ng-model="valueProperty" ng-options="option.key as option.label for option in availableDataProperties">
          <option value="">-- choose Visualization value --</option>
        </select>

        <label>Select a property that matches your selected map property</label>
        <select ng-model="mappingPropertyOnData" ng-options="option.key as option.label for option in availableDataProperties">
          <option value="">-- choose Property --</option>
        </select>

        <div ng-show="choroplethInstance.dataPointsWithMissingRegion.length > 0">
          <a class="upfront-btn upfront-btn-mini upfront-btn-danger"
              ng-click="openDataModal(choroplethInstance.dataPointsWithMissingRegion)">
            {{choroplethInstance.dataPointsWithMissingRegion.length}}
          </a>
          <small>Data Points with no corresponding region</small>
        </div>

        <label>Select the color scheme for your visualization <small>(© colorbrewer.org, Cynthia Brewer)</small></label>
        <select ng-model="colorScheme" ng-options="option.cssClass as option.name for option in availableColorSchemes">
          <option value="">-- choose Color Scheme --</option>
        </select>

        <label>Select in how many steps the color will be divided</label>
        <select ng-model="quantizeSteps" ng-options="option for option in availableQuantizeSteps">
        </select>
        <!-- TODO: Slider probably doesn't work since it needs click events on the document which are not propagated from within the sidebar -->
        <!--<slider floor="3" ceiling="9" step="1" precision="1" ng-model="bla"></slider>-->
      </div>

    </fieldset

  </form>
</div>
<div>
  <div class="upfront-snippet-grouptitle"><i class="entypo-down-open-mini"></i>Actions</div>
  <ul class="upfront-action-list" style="text-align: center">
    <li ng-show="isDeletable(snippet)">
      <button class="upfront-btn upfront-control upfront-btn-danger"
            type="button"
            ng-click="deleteSnippet(snippet)">
        <span class="entypo-trash"></span>
        <span>löschen</span>
      </button>
    </li>
  </ul>
</div>
</div>
"""
