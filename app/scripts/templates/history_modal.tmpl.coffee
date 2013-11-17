htmlTemplates.historyModal = """
<div class="upfron-modal-full-width-header">
  <h3>History for {{snippet.template.title}}</h3>
  <div class="right-content upfront-control">
    <button class="upfront-btn upfront-btn-info" ng-click="close($event)">Close table view</button>
  </div>
</div>
<div class="upfront-modal-body" style="height: 100%">
  <div ng-show="history.length == 0">
    There is no history for this snippet yet.
  </div>
  <div ng-show="history.length > 0">
    HERE COMES THE HISTORY MERGE VIEW
  </div>
</div>
<div class="upfront-modal-footer upfront-control">
  <button class="upfront-btn upfront-btn-info" ng-click="close($event)">Close</button>
</div>
"""
