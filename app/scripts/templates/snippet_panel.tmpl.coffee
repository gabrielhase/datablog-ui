upfront.angularTemplates = upfront.angularTemplates || {}

upfront.angularTemplates.snippetPanel = """
<div id="{{ controlId }}">
  <div class="upfront-sidebar-header" style="display: block;"
    ng-click="hideSidebar()">
    <i class="upfront-icon-right-bold upfront-sidebar-hide-icon"></i>
    <h3><span>Insert Snippets</span></h3>
  </div>
  <div class="upfront-sidebar-content upfront-help-small">
    <i class="upfront-icon-help-circled"></i>
    Drag & Drop or click list items
  </div>
  <ul class="upfront-snippet-list">
    <li ng-repeat="snippet in snippets" class="upfront-snippet-item" ng-class="{selected: $index==snippetInsertService.selectedSnippet}">
      <a href="" snippet-drag="{{ snippet.identifier }}" ng-click="selectSnippet($event, $index, snippet)">{{ snippet.title }}</a>
    </li>
  </ul>
</div>
"""
