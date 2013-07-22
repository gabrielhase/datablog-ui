upfront.angularTemplates = upfront.angularTemplates || {}

upfront.angularTemplates.editor = """
<div ng-controller='AuthController'>
  <div id='splash' name='form' ng-show='active'>
    <div class='cell'>
      <form name='form' id='auth' ng-submit='formSubmitted()'>
        <h2>Livingdocs</h2>
        <p class='loading' ng-show='loading'>Loading…</p>

        <ng-switch on='loading'>
          <fieldset ng-switch-when='false'>
            <p ng-show='statusMessage' class="auth-status">{{statusMessage}}</p>
            <input class="email" name='email' type='email' placeholder='Email' ng-model='$parent.email' autofocus required />
            <input class="password" name='password' type='password' placeholder='Password' ng-model='$parent.password' required />

            <input type='submit' id='submit' value='Log In' />
            <small><a href="#">Forgot your password?</a></small>
            <small><a href="#">No account? Register here</a></small>
          </fieldset>
        </ng-switch>
      </form>
    </div>
  </div>
  <div class="-js-editor-root upfront-control" ng-controller="EditorController" document-click autosave>
    <div ng-show="serverResponse" class="top-message" ng-animate="{show: 'message-show'}">
      <div ng-show="serverResponse.status == 200">
        page saved
      </div>
      <div ng-show="serverResponse.status != 200">
        There was an error saving your page
      </div>
    </div>

    <div sidebar ng-if="uiStateService.state.sidebar">
      <div document-panel ng-if="uiStateService.state.documentPanel"></div>
      <div snippet-panel ng-if="uiStateService.state.snippetPanel"></div>
    </div>

    <div popover ng-if="uiStateService.state.flowtextPopover" bounding-box="{{ boundingBox }}">
      <ng-include src="'flowtext-options.html'" ng-show="!uiStateService.state.linkPopover">
      </ng-include>
    </div>
  </div>
</div>
"""
