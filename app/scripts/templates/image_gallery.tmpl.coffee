angularTemplates.imageGallery = """
<div>
  <div class="upfront-modal-header">
    <form class="upfront-form centered upfront-control" ng-submit="search()">
      <input type="text" placeholder="Suchbegriff" ng-model="query" />
      <button type="submit" class="upfront-btn">Suche</button>
    </form>
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
    <pagination class="upront-pagination-centered upfront-pagination-inline" on-select-page="setPage(page)" rotate="false" num-pages="info.pages" current-page="info.page" max-size="3" boundary-links="true" previous-text="&lsaquo;" next-text="&rsaquo;" first-text="Erste Seite" last-text="Letzte Seite"></pagination>
    <button class="upfront-btn" ng-click="close()">Close</button>
  </div>
</div>
"""
