htmlTemplates.propertiesPanel = """
<div>
  <div class="upfront-sidebar-header" style="display: block;"
    ng-click="hideSidebar()">
    <i class="entypo-right-open-big upfront-sidebar-hide-icon"></i>
    <h3>
      <span ng-show="snippet">Properties for {{snippet.template.title}}</span>
      <span ng-hide="snippet">Select an element on the page</span>
    </h3>
  </div>
  <div ng-show="snippet">
    <div class="upfront-snippet-grouptitle"><i class="entypo-down-open-mini"></i>Visual Properties</div>
    <div class="visual-form-placeholder">
    </div>
    <form class="upfront-properties-form upfront-form">
    </form>
    <div class="upfront-snippet-grouptitle"><i class="entypo-down-open-mini"></i>Actions</div>
    <ul class="upfront-action-list" style="text-align: center">
      <li ng-show="isDeletable(snippet)">
        <button class="upfront-btn upfront-control upfront-btn-danger"
              type="button"
              ng-click="deleteSnippet(snippet)">
          <span class="entypo-trash"></span>
          <span>löschen</span>
        </button>
      </li>
    </ul>
  </div>
</div>
"""
