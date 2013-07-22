angularTemplates.flowtextOptions = """
<div ng-controller='FlowtextOptionsController'>
  <div ng-show="!linkMode" class='upfront-btn-group'>
    <a ng-click='toggleBold()'
       ng-class="{'upfront-btn-inverse': isBold}"
       class='upfront-btn'>
      Bold
    </a>

    <a ng-click='toggleItalic()'
       ng-class="{'upfront-btn-inverse': isItalic}"
       class='upfront-btn'>
      Italic
    </a>

    <a ng-click='toggleLink()'
       ng-class="{'upfront-btn-inverse': isLinked}"
       class='upfront-btn'>
      Link
    </a>

    <!--
    <a ng-click='selectBlockLevel()'>
      block
    </a>
    -->
  </div>
  <div ng-show="linkMode">
    <form>
      <input type="text" ng-model="link" style="border: 1px solid #ccc;" />
      <button ng-click="toggleLink()" class='upfront-btn'>
      OK
      </button>
    </form>
  </div>
</div>
"""
