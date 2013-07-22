upfront.angularTemplates = upfront.angularTemplates || {}

upfront.angularTemplates.editor = """
<div ng-controller='AuthController'>
  <div class="-js-editor-root upfront-control" ng-controller="EditorController" document-click autosave>

    <!-- Autosave messages -->
    <div ng-show="serverResponse" class="top-message" ng-animate="{show: 'message-show'}">
      <div ng-show="serverResponse.status == 200">
        page saved
      </div>
      <div ng-show="serverResponse.status != 200">
        There was an error saving your page
      </div>
    </div>

    <!-- Sidebar -->
    <div sidebar ng-if="uiStateService.state.sidebar">
      <div document-panel ng-if="uiStateService.state.documentPanel"></div>
      <div snippet-panel ng-if="uiStateService.state.snippetPanel"></div>
    </div>

    <!-- Selected Text Options -->
    <div popover ng-if="uiStateService.state.flowtextPopover" bounding-box="{{ boundingBox }}">
      <ng-include src="'flowtext-options.html'" ng-show="!uiStateService.state.linkPopover">
      </ng-include>
    </div>

  </div>
</div>
"""
