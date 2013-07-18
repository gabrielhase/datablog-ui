upfront.angularTemplates = upfront.angularTemplates || {}

upfront.angularTemplates.popover = """
<div class='upfront-popover-panel upfront-popover'
  style='position: absolute; left: {{left}}px; top: {{top}}px'>
  <div class='arrow'></div>
    <button class='upfront-close' ng-click='close($event, target)'>x</button>
    <div class='upfront-panel-content clearfix'>
      <div class='clearfix' ng-transclude>
      </div>
    </div>
  </div>
</div>
"""