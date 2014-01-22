htmlTemplates.diffChangeEntry = """
<div class="upfront-diff change upfront-control">
  <span class="entypo-flow-parallel"></span>
    {{property.label}} changed <span ng-show="!property.difference.type == 'blobChange'">from {{property.difference.previous}} to {{property.difference.after}}</span>
  &nbsp;<button class="upfront-btn upfront-btn-small upfront-btn-info"
                ng-click="revertChange(property)"
                ng-hide="isColorStepsWithOrdinalData(property)">
                revert to previous value
        </button>
</div>
"""
