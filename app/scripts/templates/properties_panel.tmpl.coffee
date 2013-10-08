htmlTemplates.propertiesPanel = """
<div>
  <div class="upfront-sidebar-header" style="display: block;"
    ng-click="hideSidebar()">
    <i class="entypo-right-open-big upfront-sidebar-hide-icon"></i>
    <h3><span>Properties for {{snippet.template.title}}</span></h3>
  </div>
  <div>
    <div class="upfront-snippet-grouptitle"><i class="entypo-down-open-mini"></i>Visuelles</div>
    <form class="upfront-properties-form upfront-form">
    </form>
    <div class="upfront-snippet-grouptitle"><i class="entypo-down-open-mini"></i>Aktionen</div>
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
