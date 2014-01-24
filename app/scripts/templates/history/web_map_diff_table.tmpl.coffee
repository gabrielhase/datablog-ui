htmlTemplates.webMapDiffTable = """
<div class="diff-viewer">
  <ul class="upfront-list">
    <li ng-repeat="section in versionDifference">
      <h3>{{section.sectionTitle}}</h3>
      <ul class="upfront-list">
        <li ng-repeat="property in section.properties" ng-show="property.difference">
          <div ng-if="property.key == 'markers'">
            <div ng-if="property.difference.type == 'change'">
              <div class="upfront-diff change upfront-control">
                <span class="entypo-flow-parallel"></span>
                Marker changed from {{property.difference.previous}} to {{property.difference.after}}
                &nbsp;<button class="upfront-btn upfront-btn-small upfront-btn-info"
                      ng-click="revertChange(property)">
                  revert to previous value
                </button>
              </div>
            </div>
            <div ng-if="property.difference.type == 'add'">
              <div  class="upfront-diff upfront-control add">
                <span class="entypo-plus-circled"></span>
                Marker {{property.difference.content}}
                &nbsp;<button class="upfront-btn upfront-btn-small upfront-btn-info"
                      ng-click="revertAdd(property)"
                      ng-show="property.difference.type == 'add'">
                  remove
                </button>
              </div>
            </div>
            <div ng-if="property.difference.type == 'delete'">
              <div  class="upfront-diff upfront-control delete">
                  <span class="entypo-minus-circled"></span>
                  Marker {{property.difference.content}}
                  &nbsp;<button class="upfront-btn upfront-btn-small upfront-btn-info"
                          ng-click="revertDelete(property)"
                          ng-show="property.difference.type == 'delete'">
                      bring back
                  </button>
              </div>
            </div>
          </div>
          <div ng-if="property.key != 'markers'">
            <ng-include src="'diff-change-entry.html'"></ng-include>
          </div>
        </li>
      </ul>
    </li>
  </ul>
</div>
"""
