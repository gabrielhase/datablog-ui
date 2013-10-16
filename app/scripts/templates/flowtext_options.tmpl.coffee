htmlTemplates.flowtextOptions = """
<div ng-controller='FlowtextOptionsController'>
  <div class="flowtext-options upfront-btn-group" ng-hide="editableEventsService.selectionIsOnInputField" class='upfront-btn-group'>
    <a ng-click='toggleBold()'
       ng-class="{'upfront-formatting-active': currentSelectionStyles.isBold}"
       class='upfront-btn upfront-text-format-btn'>
      <span class="fontawesome-bold"></span>
    </a>

    <a ng-click='toggleItalic()'
       ng-class="{'upfront-formatting-active': currentSelectionStyles.isItalic}"
       class='upfront-btn upfront-text-format-btn'>
      <span class="fontawesome-italic"></span>
    </a>

    <a ng-click='openLinkInput()'
       ng-class="{'upfront-formatting-active': currentSelectionStyles.isLinked}"
       class='upfront-btn upfront-text-format-btn'>
      <span class="fontawesome-link"></span>
    </a>

  </div>
  <div ng-show="editableEventsService.selectionIsOnInputField">
    <form class="upfront-control upfront-link-editing" ng-submit="setLink(currentSelectionStyles.link, currentSelectionStyles.isLinkExternal)">
      <input type="submit" class='upfront-btn-mini upfront-link-editing_submit' value="OK">
      <input  type="text"
              id="linkInput"
              class="upfront-link-editing_link-field"
              placeholder="www.datablog.io"
              ld-focus="{{editableEventsService.selectionIsOnInputField}}"
              ng-model="currentSelectionStyles.link">

      <label class="upfront-link-editing_checkbox">
        <input type="checkbox"
              ng-model="currentSelectionStyles.isLinkExternal"> In neuem Fenster öffnen
      </label>
    </form>
  </div>
</div>
"""
