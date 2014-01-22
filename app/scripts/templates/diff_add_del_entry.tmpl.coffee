htmlTemplates.diffAddDelEntry = """
<div  class="upfront-diff upfront-control"
      ng-class="{'add': property.difference.type == 'add', 'delete': property.difference.type == 'delete'}">

  <span ng-show="property.difference.type == 'add'"
        class="entypo-plus-circled"></span>

  <span ng-show="property.difference.type == 'delete'"
        class="entypo-minus-circled"></span>

  {{property.label}} {{property.difference.content}}


  &nbsp;<button class="upfront-btn upfront-btn-small upfront-btn-info"
                ng-click="revertAdd(property)"
                ng-show="property.difference.type == 'add'">
                remove
        </button>

  &nbsp;<button class="upfront-btn upfront-btn-small upfront-btn-info"
              ng-click="revertDelete(property)"
              ng-show="property.difference.type == 'delete'">
              bring back
      </button>

</div>
"""
