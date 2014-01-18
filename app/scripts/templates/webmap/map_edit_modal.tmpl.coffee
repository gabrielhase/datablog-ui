htmlTemplates.mapEditModal = """
<div class="upfron-modal-full-width-header">
  <h3>Freeform Editing for your Map</h3>
  <div class="right-content upfront-control">
    <button class="upfront-btn upfront-btn-info"
            ng-click="close($event)">
            Close Freeform Editing
    </button>
  </div>
</div>
<div class="upfront-modal-body" style="height: 100%">
  <leaflet center="center" markers="markers" event-broadcast="events" tiles="tiles" style="height: 100%">
  </leaflet>

  <div popover ng-if="editState.markerSelected" placement="no-arrow" arrow-distance="0" bounding-box="{{ editState.markerPropertiesBB }}" open-condition="editState.markerSelected">
    <form class="upfront-form upfront-control">
      <legend>Selected Marker</legend>
      <label>Icon</label>
      <span ng-repeat="icon in uiModel.getAvailableIcons()"
                      class="fa fa-{{icon}}"
                      ng-class="{'upfront-icon-selected': icon == editState.markerSelected.icon.options.icon}"
                      style="padding-right: 5px;"
                      ng-click="selectIcon(editState.markerSelected, icon)"></span>
      <label>Popover Text (optional)</label>
      <input style="width: 90%" ng-model="editState.markerSelected.message">
      <a href="" class="upfront-btn upfront-btn-small upfront-btn-danger"
          ng-click="removeMarker(editState.markerSelected)">
          Delete
      </a>
      <a href="" class="upfront-btn upfront-btn-small upfront-btn-success"
          ng-click="disableMarkerSelectedState()">
          Accept
      </a>
    </form>
  </div>

  <div popover ng-if="editState.addMarker" arrow-distance="14" bounding-box="{{ editState.boundingBox }}" popover-css-class="upfront-popover--minimal">
    <div class="upfront-control">
      <a  href="" class="upfront-btn upfront-text-format-btn entypo-location"
          ng-click="addMarker($event)">
          Add marker
      </a>
    </div>
  </div>
</div>
<div class="upfront-modal-footer upfront-control">
  <button class="upfront-btn upfront-btn-info"
          ng-click="close($event)">Close Freeform Editing</button>
</div>
"""
