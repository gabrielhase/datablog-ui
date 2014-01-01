htmlTemplates.documentPanel = """
<div>
  <div class="upfront-sidebar-header" style="display: block;"
    ng-click="hideSidebar()">
    <i class="entypo-right-open-big upfront-sidebar-hide-icon"></i>
    <h3>{{ document.title }}</h3>
  </div>
  <div class="upfront-sidebar-content upfront-help-small">
    <h4>Thank you for trying datablog.io!</h4>
    <p>
      This public Test Page allows you to try the features of datablog, in particular choropleths and maps.
      Your work is stored locally, but not on any server, so when your Browser is reset, the data is lost.
      If you have any suggestions or ideas concerning datablog I am happy to hear about it at "gabriel(dot)hase(at)gmail(dot)com".
    </p>
    <a  href="" class="upfront-btn upfront-btn-danger"
        ng-click="resetStory()">
        Reset Test Story
    </a>
    <br>
    <span class="entypo-help" style="font-size: 0.8em"> This clears all changes you have made to the Test Page</span>
  </div>
</div>
"""
