htmlTemplates.dataModal = """
<div class="upfron-modal-full-width-header">
  <h3>Your Dataset</h3>
  <div class="right-content upfront-control">
    <button class="upfront-btn upfront-btn-info" ng-click="close($event)">Close table view</button>
  </div>
</div>
<div class="upfront-modal-body" style="height: 100%">
  <div class="gridStyle" ng-grid="gridOptions">

  </div>
</div>
<div class="upfront-modal-footer upfront-control">
  <button class="upfront-btn upfront-btn-info" ng-click="close($event)">Close</button>
</div>
"""
