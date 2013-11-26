htmlTemplates.diffAddDelEntry = """
<div  class="upfront-diff"
      ng-class="{'add': property.difference.type == 'add', 'delete': property.difference.type == 'delete'}"
      ng-controller="MergeController">
  <span ng-show="property.difference.type == 'add'"
        class="entypo-plus-circled"
        ng-click="revertAdd(property)"></span>
  <span ng-show="property.difference.type == 'delete'"
        class="entypo-minus-circled"
        ng-click="revertDelete(property)"></span>
  {{property.label}} {{property.difference.content}}
</div>
"""
