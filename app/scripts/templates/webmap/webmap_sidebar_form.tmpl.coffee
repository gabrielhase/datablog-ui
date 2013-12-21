htmlTemplates.webmapSidebarForm = """
<div class="upfront-sidebar-content-wrapper">
  <div  class="upfront-sidebar-content"
        ng-controller="WebMapFormController">
    <form class="upfront-form" name="webMapForm">
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
                type="number" min="-90" max="90"
                ng-model="center.lat"
                required>
      </fieldset>
      <fieldset>
        <legend>Kickstart</legend>
        <label>Upload a geojson to kickstart your locations</label>
        <input json-upload callback="kickstartPins(data, error)" type="file" name="data"></input>
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
          <span>löschen</span>
        </button>
      </li>
    </ul>
  </div>
</div>
"""
