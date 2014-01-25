htmlTemplates.choroplethDiffPreview = """
<div class="preview-wrapper">
  <div class="history-explorer">
    <div class="upfront-timeline">
      <ol class="upfront-timeline-entries"
          style="left: 0px;">

        <li role="tab"
            ng-click="chooseRevision(historyEntry)"
            class="upfront-timeline-entry active-entry latest-entry"
            ng-repeat="historyEntry in history | orderBy:'revisionId':reverse"
            data-version="{{historyEntry.revisionId}}"
            data-timestamp="{{historyEntry.lastChanged}}">
          <a ng-class="{'selected': isSelected(historyEntry)}">
            <span ng-class="{'arrow arrow-bottom': isSelected(historyEntry)}"></span>
          </a>
        </li>

      </ol>
    </div>

    <div class="current-history-map hide-legend">

    </div>
  </div>

  <div class="latest-preview">

    <h2>Current Version</h2>
    <div class="latest-version-map hide-legend">
    </div>
  </div>
</div>
"""
