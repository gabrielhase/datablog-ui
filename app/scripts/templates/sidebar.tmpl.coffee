upfront.angularTemplates = upfront.angularTemplates || {}

upfront.angularTemplates.sidebar = """
<div class="upfront-sidebar" id="{{controlId}}"
  ng-class="{'upfront-sidebar-hidden': sidebarHidden}">
  <div class="upfront-sidebar-nav">
    <i class="entypo-feather upfront-sidebar-nav-elem upfront-sidebar-nav-first"
      data-nav="document"
      ng-click="loadDocument()"
      ng-class="{'active': uiStateService.state.documentPanel}"></i>
    <i class="upfront-sidebar-nav-elem upfront-sidebar-nav-second"
      data-nav="snippets" style="font-weight:700;"
      ng-click="loadSnippets()"
      ng-class="{'active': uiStateService.state.snippetPanel}">+</i>
  </div>

  <div class="upfront-sidebar-header">
    <i class="upfront-icon-right-bold upfront-sidebar-hide-icon"></i>
    <h3><span></span></h3>
  </div>

  <div class="upfront-sidebar-body" ng-transclude>
  </div>
</div>
"""
