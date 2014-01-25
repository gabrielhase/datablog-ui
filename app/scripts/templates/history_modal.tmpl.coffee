htmlTemplates.historyModal = """
<div class="upfron-modal-full-width-header">
  <h3>History for {{snippet.template.title}}</h3>
  <div class="right-content upfront-control">
    <button ng-hide="modalState.isMerging"
            class="upfront-btn upfront-btn-info"
            ng-click="close($event)">Close table view</button>
    <button ng-show="modalState.isMerging"
            class="upfront-btn upfront-btn-danger"
            ng-click="close($event)">Cancel Merging</button>
    &nbsp;
    <button ng-show="modalState.isMerging"
            class="upfront-btn upfront-btn-large upfront-btn-success"
            ng-click="merge($event)">Merge changes</button>
  </div>
</div>
<div class="upfront-modal-body" style="height: 100%">

  <div ng-if="snippet.identifier == 'livingmaps.choropleth'" ng-controller="ChoroplethMergeController">
    <div ng-show="history.length == 0">
      There is no history for this snippet in the last 10 revisions (only the 10 latest revisions are stored in demo mode).
    </div>

    <div class="upfront-snippet-history" ng-show="history.length > 0">
      <ng-include src="'choropleth-diff-preview.html'"></ng-include>
      <ng-include src="'choropleth-diff-table.html'"></ng-include>
    </div>
  </div>

  <div ng-if="snippet.identifier == 'livingmaps.map'" ng-controller="WebMapMergeController">
    <div ng-show="history.length == 0">
      There is no history for this snippet in the last 10 revisions (only the 10 latest revisions are stored in demo mode).
    </div>

    <div class="upfront-snippet-history" ng-show="history.length > 0">
      <ng-include src="'choropleth-diff-preview.html'"></ng-include>
      <ng-include src="'web-map-diff-table.html'"></ng-include>
    </div>
  </div>

</div>
<div class="upfront-modal-footer upfront-control">
  <button ng-hide="modalState.isMerging"
            class="upfront-btn upfront-btn-info"
            ng-click="close($event)">Close table view</button>
</div>
"""
