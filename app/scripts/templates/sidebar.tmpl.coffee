htmlTemplates.sidebar = """
<div class="upfront-sidebar" id="{{controlId}}"
  ng-class="{'upfront-sidebar-hidden': !foldedOut}">
  <div class="upfront-sidebar-nav">
    <span class="entypo-feather upfront-sidebar-nav-elem upfront-sidebar-nav-first"
      data-nav="document"
      ng-click="loadDocument()"
      ng-class="{'active': uiStateService.state.isActive('documentPanel')}"></span>
    <span class="upfront-sidebar-nav-elem upfront-sidebar-nav-second"
      data-nav="snippets" style="font-weight:700;"
      ng-click="loadSnippets()"
      ng-class="{'active': uiStateService.state.isActive('snippetPanel')}">+</span>
    <span class="entypo-cog upfront-sidebar-nav-elem upfront-sidebar-nav-third"
       data-nav="properties"
       ng-click="loadProperties()"
       ng-class="{'active': uiStateService.state.isActive('propertiesPanel')}"></span>
  </div>

  <div class="upfront-sidebar-header">
    <i class="entypo-right-open-big upfront-sidebar-hide-icon"></i>
    <h3><span></span></h3>
  </div>

  <div class="upfront-sidebar-body" ng-transclude>
  </div>
</div>
"""
