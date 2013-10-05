htmlTemplates.documentPanel = """
<div id="{{ controlId }}">
  <div class="upfront-sidebar-header" style="display: block;"
    ng-click="hideSidebar()">
    <i class="entypo-right-open-big upfront-sidebar-hide-icon"></i>
    <h3>{{ document.title }}</h3>
  </div>
  <div class="upfront-sidebar-content upfront-help-small">
    <i class="entypo-help"></i>
    publish if you want
  </div>
  <div class="upfront-sidebar-content -js-upfront-sidebar-publish">
    <button class="upfront-btn upfront-control upfront-btn-primary" type="button">
      <i class="entypo-upload-cloud"></i>
      <span>publish</span>
    </button>
  </div>
</div>
"""
