htmlTemplates.choroplethSidebarForm = """
<div class="upfront-sidebar-content-wrapper">
  <div  class="upfront-sidebar-content"
        ng-controller="ChoroplethFormController">
    <form class="upfront-form">
      <fieldset>
        <legend>Map Properties</legend>

        <label>Select a Map from our collection</label>
        <select ng-model="mapName" ng-options="option as option.name for option in predefinedMaps">
          <option value="">-- choose Map --</option>
        </select>

        <label>or upload (geojson files only)</label>
        <input json-upload callback="setMap(data, error)" type="file" name="map"></input>

        <label>Geographical projection</label>
        <select ng-model="projection" ng-options="option.value as option.name for option in projections">
          <option value="">-- choose Projection --</option>
        </select>

      </fieldset>
      <fieldset>
        <legend>Data Mapping</legend>

        <label>Select a property that can be matched by your data</label>
        <select ng-model="mappingPropertyOnMap" ng-options="option.value as option.label for option in availableMapProperties">
          <option value="">-- choose Property --</option>
        </select>

        <div class="upfront-well red" ng-show="availableDataMappingProperties.length == 0">
          No column of your data file can be mapped to the selected mapping property on your map.
          Select a different mapping property on the map or change your data.
        </div>

        <div class="upfront-well green" ng-show="availableDataMappingProperties.length == 1">
          <span class="entypo-check"></span> Successfully mapped on data column '{{availableDataMappingProperties[0].key}}'
          <div ng-show="choroplethInstance.regionsWithMissingDataPoints.length > 0">
            <span class="entypo-attention"></span> {{choroplethInstance.dataPointsWithMissingRegion.length}}
            <small> Regions not visualized on the map</small>
          </div>
        </div>

        <div ng-show="availableDataMappingProperties.length > 1">
          <label>Select a property that matches your selected map property</label>
          <select ng-model="mappingPropertyOnData" ng-options="option.key as option.label for option in availableDataMappingProperties">
            <option value="">-- choose Property --</option>
          </select>
        </div>

      </fieldset>
      <fieldset>
        <legend>Data Visualization</legend>

        <div ng-show="mappingPropertyOnMap">
          <label>Data File (.csv, comma-separated)</label>
          <input csv-upload callback="setData(data, error)" type="file" accept=".csv" name="data"></input>
          <div ng-show="snippet.model.data('data')">
            Your Data File:
            <a class="upfront-btn upfront-btn-mini upfront-btn-success"
                ng-click="openDataModal(choroplethInstance.dataPointsWithMissingRegion)">
              {{snippet.model.data('data').length}} rows
            </a>
          </div>

          <label>Property to visualize</label>
          <select ng-model="valueProperty" ng-options="option.key as option.label for option in availableDataProperties">
            <option value="">-- choose Visualization value --</option>
          </select>

          <div ng-show="choroplethInstance.dataPointsWithMissingRegion.length > 0">
            <a class="upfront-btn upfront-btn-mini upfront-btn-danger"
                ng-click="openDataModal(choroplethInstance.dataPointsWithMissingRegion)">
              {{choroplethInstance.dataPointsWithMissingRegion.length}}
            </a>
            <small>Data Points with no corresponding region</small>
          </div>

          <label>Color scheme <small>(© colorbrewer.org, Cynthia Brewer)</small></label>
          <select ng-model="colorScheme" ng-options="option.cssClass as option.name for option in availableColorSchemes">
            <option value="">-- choose Color Scheme --</option>
          </select>

          <div class="upfront-well red" ng-show="isCategorical && hasTooManyCategories()">
            The chosen categorical value has too many categories for this color scheme.
            Choose a different color scheme or change the visualized value.
          </div>

          <div ng-show="!isCategorical">
            <label>Nr. of different colors</label>
            <select ng-model="colorSteps" ng-options="option for option in availableColorSteps">
            </select>
            <!-- TODO: Slider probably doesn't work since it needs click events on the document which are not propagated from within the sidebar -->
            <!--<slider floor="3" ceiling="9" step="1" precision="1" ng-model="bla"></slider>-->
          </div>

        </div>

      </fieldset>
      <fieldset>
        <legend>legend</legend>
        <label>
          <input type="checkbox" ng-model="hideLegend" /> Hide legend
        </label>
      </fieldset>

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
          <span>delete</span>
        </button>
      </li>
    </ul>
  </div>
</div>
"""
