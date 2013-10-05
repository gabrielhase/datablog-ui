htmlTemplates.imageGallery = """
<div>
  <div class="upfront-modal-header">
    <h3>Some great example pictures</h3>
  </div>
  <div class="upfront-modal-body">
    <ul class="upfront-thumbnails">
      <li ng-repeat="image in images">
        <div class="upfront-thumbnail" ng-click="addImage(image)">
          <span class="entypo-plus-squared" style="float: left"></span>
          <img ng-src="{{image.thumbnail}}" />
          <div class="upfront-caption">
            <p>
              {{image.caption}}
            </p>
            <p>
              Source: {{image.source}}
            </p>
          </div>
        </div>
      </li>
    </ul>
  </div>
  <div class="upfront-modal-footer upfront-control">
    <button class="upfront-btn" ng-click="close()">Close</button>
  </div>
</div>
"""
