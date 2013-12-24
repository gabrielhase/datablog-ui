htmlTemplates.sidebarRegion = """
<div class="upfront-sidebar-region clearfix" ng-class="{'upfront-sidebar-region-closed': !showContent}">
  <div class="upfront-sidebar-region-header" ng-click="toggle()">
    <span ng-class="{'entypo-down-open-mini': showContent, 'entypo-right-open-mini': !showContent}"></span>
    <div class="upfront-sidebar-region-header-caption">{{caption}}</div>
    <span class="upfront-sidebar-region-header-icon" ng-class="iconClass"></span>
  </div>
  <div class="upfront-sidebar-region-content" ng-show="showContent" ng-transclude></div>
</div>
"""
