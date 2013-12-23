htmlTemplates.mapKickstartModal = """
<div class="upfron-modal-full-width-header">
  <h3>Import data from your geojson file</h3>
  <div class="right-content upfront-control">
    <button class="upfront-btn upfront-btn-info" ng-click="close($event)">Close kickstart view</button>
  </div>
</div>
<div class="upfront-modal-body" style="height: 100%">

  <div style="width: 40%; float: left;">
    <form class="upfront-form">
      <table class="table table-bordered">
        <thead>
          <tr>
            <td>#</td>
            <td><b>Inlcude this pin</b></td>
            <td>
              <b>Property for Popover Text</b>
            </td>
            <td><b>Popover Text</b></td>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>Global:</td>
            <td><input type="checkbox" ng-model="globalValues.selected"></td>
            <td>
              <select ng-model="globalValues.textProperty" ng-options="property for property in globalTextProperties">
                <option value="">-- reset all --</option>
              </select>
            </td>
            <td></td>
          </tr>
          <tr ng-repeat="marker in markers"
              ng-class="{'success': marker.selected}"
              ng-mouseover="highlightMarker($index)"
              ng-mouseleave="unHighlightMarker($index)"
              ng-click="toggleMarker(marker, $index)">
            <td>{{$index}}</td>
            <td>
              <input type="checkbox" ng-checked="marker.selected">
            </td>
            <td>
              <select ng-model="marker.selectedTextProperty" ng-options="property for property in marker.textProperties">
                <option value="">-- no text initialization --</option>
              </select>
            </td>
            <td>
              {{marker.geojson.properties[marker.selectedTextProperty] | characters: 40}}
            </td>
          </tr>
        </tbody>

      </table>
    </form>
  </div>
  <div style="width: 40%; position: absolute; right: 10px;">
    <leaflet center="center" markers="previewMarkers" event-broadcast="events"></leaflet>
  </div>

</div>
<div class="upfront-modal-footer upfront-control">
  <button class="upfront-btn upfront-btn-info"
          ng-click="close($event)">Close kickstart view</button>
</div>
"""
