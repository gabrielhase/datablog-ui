htmlTemplates.editor = """
<div>
  <div class="-js-editor-root upfront-control" ng-controller="EditorController" document-click autosave>

    <!-- Autosave messages -->
    <div class='top-message'
         ng-show="autosave.state"
         ng-class="autosave.state"
         ng-animate="{show: 'message-show'}">
      {{ autosave.message }}
    </div>

    <!-- Sidebar -->
    <div sidebar ng-if="state.isActive('sidebar')" folded-out="state.sidebar.foldedOut">
      <div document-panel ng-if="state.isActive('documentPanel')"></div>
      <div snippet-panel ng-if="state.isActive('snippetPanel')"></div>
      <div properties-panel snippet="state.propertiesPanel.snippet" ng-if="state.isActive('propertiesPanel')"></div>
    </div>

    <!-- Selected Text Options -->
    <div popover ng-if="state.isActive('flowtextPopover')" arrow-distance="14" open-condition="state.flowtextPopover" bounding-box="{{ textPopoverBoundingBox }}" popover-css-class="upfront-formatting-popover">
      <ng-include src="'flowtext-options.html'">
      </ng-include>
    </div>

    <!-- Selected Image Popover -->
    <div popover ng-if="state.isActive('imagePopover')" arrow-distance="14" open-condition="state.imagePopover" bounding-box="{{ state.imagePopover.boundingBox }}">
      <ng-include src="'image-input.html'"></ng-include>
    </div>

  </div>
</div>
"""
