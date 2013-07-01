angularTemplates.snippetPanel = """
<div id="{{ controlId }}">
  <div class="upfront-sidebar-header" style="display: block;"
    ng-click="hideSidebar()">
    <i class="entypo-right-open-big upfront-sidebar-hide-icon"></i>
    <h3><span>Insert Snippets</span></h3>
  </div>
  <div class="upfront-sidebar-content upfront-help-small">
    <i class="entypo-help"></i>
    Drag & Drop or click list items
  </div>
  <div class="upfront-snippet-wrapper">
    <ul class="upfront-snippet-list" ng-repeat="group in groups">
      <li class="upfront-snippet-grouptitle"><i class="entypo-down-open-mini"></i>{{ group.title }}</li>
      <li ng-repeat="snippet in group.templates" class="upfront-snippet-item" ng-class="{selected: $index==snippetInsertService.selectedSnippet}">
        <a href="" snippet-drag="{{ snippet.identifier }}" ng-click="selectSnippet($event, $index, snippet)">{{ snippet.title }}</a>
      </li>
    </ul>
  </div>
</div>
"""
