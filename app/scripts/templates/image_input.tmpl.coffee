htmlTemplates.imageInput = """
<form class="upfront-form" style="width: 300px" ng-submit="embedImage(imageUrl)" ng-controller="ImageEmbedController">
  <label>Paste Image Url</label>
  <textarea class="full-width" rows="5" ng-model="imageUrl">
  </textarea>
  <br/>
  <input type="submit" class="upfront-btn" value="embed" />
</form>
"""
