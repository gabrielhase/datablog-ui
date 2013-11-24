htmlTemplates.diffAddDelEntry = """
<div class="upfront-diff" ng-class="{'add': property.difference.type == 'add', 'delete': property.difference.type == 'delete'}">
  <span ng-show="property.difference.type == 'add'"
        class="entypo-plus-circled"></span>
  <span ng-show="property.difference.type == 'delete'"
        class="entypo-minus-circled"></span>
  {{property.label}} {{property.difference.content}}
</div>
"""
