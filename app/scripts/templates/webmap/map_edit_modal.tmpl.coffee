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
  <leaflet center="center" markers="markers" event-broadcast="events" style="height: 100%">
  </leaflet>
</div>
<div class="upfront-modal-footer upfront-control">
  <button class="upfront-btn upfront-btn-info"
          ng-click="close($event)">Close Freeform Editing</button>
</div>
"""
