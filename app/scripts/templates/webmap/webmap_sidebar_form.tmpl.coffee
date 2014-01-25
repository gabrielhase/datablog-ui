htmlTemplates.webmapSidebarForm = """
<div class="upfront-sidebar-content-wrapper">
  <div  class="upfront-sidebar-content"
        ng-controller="WebMapFormController">
    <form class="upfront-form" name="webMapForm">
      <fieldset>
        <a  href="" style="margin-left: 20px;" class="upfront-btn upfront-btn-large upfront-btn-info"
            ng-click="openFreeformEditor()">
          Open Freeform Editor
        </a>
      </fieldset>
      <fieldset>
        <legend>Map Viewbox</legend>

        <label>Select a zoom level</label>
        <select ng-model="center.zoom" ng-options="zoom for zoom in availableZoomLevels">
          <option value="">-- choose Zoom Level --</option>
        </select>
        <label>Enter a longitude</label>
        <input  style="width: 80%"
                type="number" min="-180" max="180"
                ng-model="center.lng"
                required>
        <label>Enter a latitude</label>
        <input  style="width: 80%"
                type="number" min="-90" max="90"3
                ng-model="center.lat"
                required>
      </fieldset>
      <fieldset>
        <legend>Tile Layer</legend>
        <select ng-model="tileLayer" ng-options="value.name as value.name for (key, value) in uiModel.getAvailableTileLayers()">
          <option value="">-- choose Tile Layer --</option>
        </select>
        <div class="upfront-well red" ng-show="tileLayer == 'mapbox'">
          Mapbox is a commercial tile layer and this app uses a free test account. If you don't see the map, probably the quota for the free version was reached.
          DON'T RELY ON THIS TILE LAYER ON DATABLOG.IO!
        </div>
      </fieldset>
      <fieldset>
        <legend>Kickstart</legend>
        <label>Upload a geojson to kickstart your locations</label>
        <input json-upload callback="kickstartMarkers(data, error)" type="file" name="data"></input>
      </fieldset>
      <fieldset>
        <legend>Markers</legend>
        <div sidebar-region caption="Add Marker" style="margin-bottom: 10px">
          <label>Location (lng, lat)</label>
            <input class="half-width left"
              type="number" min="-180" max="180"
              ng-model="newMarker.lng"
              required>
            <input class="half-width left"
              type="number" min="-90" max="90"
              ng-model="newMarker.lat"
              required>
            <label>Popover Text</label>
            <input style="width: 80%"
                ng-model="newMarker.message">
            <a  href=""
                ng-click="addMarker()"
                class="upfront-btn upfront-btn-success">
              Add Marker
            </a>
        </div>
        <div sidebar-region caption="All Markers">
          <ul class="upfront-list">
            <li ng-repeat="marker in markers"
                ng-mouseover="highlightMarker($index)"
                ng-mouseleave="unHighlightMarker($index)">
              <a  href=""
                  class="upfront-btn upfront-btn-danger upfront-btn-mini upfront-delete-btn"
                  ng-click="deleteMarker($index)">X</a>
              <label>Location (lng, lat)</label>
              <input class="half-width left"
                type="number" min="-180" max="180"
                ng-model="marker.lng"
                required>
              <input class="half-width left"
                type="number" min="-90" max="90"
                ng-model="marker.lat"
                required>
              <label>Popover Text</label>
              <input style="width: 80%"
                ng-model="marker.message">

              <div>
                <label>Select Icon</label>
                <span ng-repeat="icon in uiModel.getAvailableIcons()"
                      class="fa fa-{{icon}}"
                      ng-class="{'upfront-icon-selected': icon == marker.icon.options.icon}"
                      style="padding-right: 5px;"
                      ng-click="selectIcon(marker, icon)"></span>
              </div>

            </li>
          </ul>
        </div>
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
