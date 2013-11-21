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
  <div class="upfront-snippet-history" ng-show="history.length > 0">
    <div class="history-explorer">


      <div class="upfront-timeline">
        <ol class="upfront-timeline-entries"
            style="width: 76px; left: 0px;">

          <li role="tab"
              ng-click="chooseRevision(historyEntry)"
              class="upfront-timeline-entry active-entry latest-entry"
              ng-repeat="historyEntry in history | orderBy:'revisionId':reverse"
              data-version="{{historyEntry.revisionId}}"
              data-timestamp="{{historyEntry.lastChanged}}">
            <a ng-class="{'selected': isSelected(historyEntry)}">
              <span ng-class="{'arrow arrow-top': isSelected(historyEntry)}"></span>
            </a>
          </li>

        </ol>
      </div>

      <div class="current-history-map">

      </div>
    </div>

    <div class="latest-preview">
      <h2>Current Version</h2>
      <div class="latest-version-map">
      </div>

    </div>


    <div class="diff-viewer">
      HERE COMES THE HISTORY MERGE VIEW
    </div>
  </div>
</div>
<div class="upfront-modal-footer upfront-control">
  <button class="upfront-btn upfront-btn-info" ng-click="close($event)">Close</button>
</div>
"""
