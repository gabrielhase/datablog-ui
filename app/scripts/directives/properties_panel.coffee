angular.module('ldEditor').directive 'propertiesPanel', ($compile, dataService) ->

  return {
    restrict: 'A'
    scope: {
      snippet: '='
    }
    template: angularTemplates.propertiesPanel
    replace: true
    controller: PropertiesPanelController
    require: '^sidebar'
    link: (scope, element, attrs, SidebarController) ->
      scope.hideSidebar = => SidebarController.hideSidebar('propertiesPanel')

      # changes in the selected snippet trigger a re-render of the properties panel
      scope.$watch('snippet', (newVal, oldVal) ->
        if newVal
          renderStyles(newVal?.template?.styles, newVal)
          renderData(newVal.data, newVal) if newVal.model.identifier == 'livingmaps.map'
      )

      formElementScopes = [] # stores the scopes of all dynamically added form elements

      renderCheckbox = (label, cssClass, snippet) ->
        insertScope = scope.$new()
        formElementScopes.push(insertScope)
        $compile(
          """
          <label class="checkbox">
            <input type="checkbox" ng-model="classSelected"> {{label}}
          </label>
          """
        )(insertScope, (checkbox, childScope) ->
          childScope.label = label
          childScope.cssClass = cssClass
          childScope.htmlElement = checkbox

          # TODO: get current state of the class on the snippet
          # classSelected = snippet.getStyle(label)

          childScope.$watch('classSelected', (newVal, oldVal) ->
            if newVal
              log.debug "setting class on snippet"
              # snippet.setStyle(label, cssClass)
            else
              log.debug "removing class from snippet"
              # snippet.setStyle(label, '')
          )

          $(".upfront-properties-form").append(checkbox)
        )


      renderSelect = (label, options, snippet) ->
        insertScope = scope.$new()
        formElementScopes.push(insertScope)
        $compile(
          """
          <label>{{label}}:</label>
          <select ng-model="classSelected" ng-options="cssLabel for (cssLabel, cssClass) in options">
            <option value="">-- {{label}} wählen --</option>
          </select>
          """
        )(insertScope, (select, childScope) ->
          childScope.htmlElement = select
          childScope.label = label
          childScope.options = options

          # TODO: get and set the current value from the class on the snippet
          # classSelected = snippet.getStyle(label)

          childScope.$watch('classSelected', (newVal, oldVal) ->
            log.debug "changed dropdown to #{newVal}"
            # snippet.setStyle(label, newVal)
          )

          $(".upfront-properties-form").append(select)
        )


      cleanForm = ->
        for elemScope in formElementScopes
          elemScope.htmlElement.remove()
          elemScope.$destroy()


      deduceFormElement = (entry) ->
        # definition in design.js takes precedence
        return entry.formElement if entry.formElement
        if typeof(entry.css) == 'string'
          'checkbox'
        else if typeof(entry.css) == 'object'
          'select'
        else
          undefined


      renderStyles = (styles, snippet) ->
        cleanForm()
        for entry in styles
          formElement = deduceFormElement(entry)
          switch formElement
            when "checkbox" then renderCheckbox(entry.name, entry.css, snippet)
            when "select" then renderSelect(entry.name, entry.css, snippet)
            else log.error("unknown form element #{formElement} for style #{entry.name}")


      renderDataSelect = (label, options, snippet) ->
        insertScope = scope.$new()
        formElementScopes.push(insertScope)
        $compile(
          """
          <label>{{label}}:</label>
          <select ng-model="selectedData" ng-options="option.value as option.name for option in options">
            <option value="">-- choose {{label}} --</option>
          </select>
          """
        )(insertScope, (select, childScope) ->
          childScope.htmlElement = select
          childScope.label = label
          childScope.options = options

          childScope.selectedData = snippet.model.data('dataIdentifier')

          childScope.$watch('selectedData', (newVal, oldVal) ->
            snippet.model.data('dataIdentifier', newVal)
            snippet.model.data('geojson', dataService.get(newVal))
          )

          $(".upfront-properties-form").append(select)
        )



      renderData = (data, snippet) ->
        renderDataSelect('Mock Data', dataService.options(), snippet)
        #snippet.model.data('geojson', data)
  }
