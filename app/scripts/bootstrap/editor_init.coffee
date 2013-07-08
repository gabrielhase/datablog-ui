@upfront = @upfront || {}

upfront.angular = do ->


  $(document).ready () ->
    upfront.angular.init()


  init: ->
    $root = $(
      """
      <div class="-js-editor-root upfront-control" ng-controller="EditorController">
        <h1>{{message}}</h1>
        {{server}}
        <div id='splash' name='form' ng-controller='AuthController' ng-show='active'>
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
      </div>
      """
    ).appendTo(document.body)
    angular.bootstrap( $root[0], ["ldEditor"] )
