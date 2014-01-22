htmlTemplates.choroplethDiffTable = """
<div class="diff-viewer">
  <ul class="upfront-list">
    <li ng-repeat="section in versionDifference">
      <h3>{{section.sectionTitle}}</h3>
      <ul class="upfront-list">
        <li ng-repeat="property in section.properties" ng-show="property.difference">
          <div ng-if="property.difference.type == 'change' || property.difference.type == 'blobChange'">
            <ng-include src="'diff-change-entry.html'"></ng-include>
          </div>
          <div ng-if="property.difference.type == 'add' || property.difference.type == 'delete'">
            <ng-include src="'diff-add-del-entry.html'"></ng-include>
          </div>
        </li>
      </ul>
    </li>
  </ul>
</div>
"""
