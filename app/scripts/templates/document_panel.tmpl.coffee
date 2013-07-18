upfront.angularTemplates = upfront.angularTemplates || {}

upfront.angularTemplates.documentPanel = """
<div id="{{ controlId }}">
  <div class="upfront-sidebar-header" style="display: block;"
    ng-click="hideSidebar()">
    <i class="upfront-icon-right-bold upfront-sidebar-hide-icon"></i>
    <h3>{{ document.title }}</h3>
  </div>
  <div class="upfront-sidebar-content upfront-help-small">
    <i class="upfront-icon-help-circled"></i>
    publish if you want
  </div>
  <div class="upfront-sidebar-content -js-upfront-sidebar-publish">
    <button class="upfront-btn upfront-control upfront-btn-primary" type="button">
      <i class="upfront-icon-upload-cloud"></i>
      <span>publish</span>
    </button>
  </div>
</div>
"""
