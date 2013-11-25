htmlTemplates.diffChangeEntry = """
<div class="upfront-diff change" ng-controller="MergeController">
  <span class="entypo-flow-parallel"></span> {{property.label}} changed from {{property.difference.previous}} to {{property.difference.after}}
  &nbsp;<button class="btn" ng-click="revertChange(property)">revert to previous value</button>
</div>
"""
