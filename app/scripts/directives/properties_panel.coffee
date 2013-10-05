angular.module('ldEditor').directive 'propertiesPanel', ($compile, dataService) ->

  return {
    restrict: 'A'
    scope: {
      snippet: '='
    }
    template: htmlTemplates.propertiesPanel
    replace: true
    controller: PropertiesPanelController
    require: '^sidebar'
    link: (scope, element, attrs, SidebarController) ->
      scope.hideSidebar = => SidebarController.hideSidebar('propertiesPanel')

      # changes in the selected snippet trigger a re-render of the properties panel
      scope.$watch('snippet', (newVal, oldVal) ->
        if newVal
          renderData(newVal.data, newVal) if newVal.model.identifier == 'livingmaps.map'
      )

      formElementScopes = [] # stores the scopes of all dynamically added form elements

      cleanForm = ->
        for elemScope in formElementScopes
          elemScope.htmlElement.remove()
          elemScope.$destroy()


      renderPopupPropertySelect = (scope, label, snippet) ->
        $compile(
          """
          <label>{{label}}:</label>
          <select ng-model="selectedProperty" ng-options="option for option in options">
            <option value="">-- choose {{label}} --</option>
          </select>
          """
        )(scope, (select, childScope) ->
          childScope.propertySelectElem = select
          childScope.label = label
          childScope.options = []

          for feature in snippet.model.data('geojson').features
            for key, value of feature.properties
              if childScope.options.indexOf(key) == -1
                childScope.options.push(key)

          childScope.selectedProperty = snippet.model.data('popupContentProperty')

          childScope.$watch('selectedProperty', (newVal, oldVal) ->
            snippet.model.data('popupContentProperty', newVal)
          )

          return select;
        )


      renderDataSelect = (label, options, snippet) ->
        insertScope = scope.$new()
        formElementScopes.push(insertScope)
        $compile(
          """
          <label>{{label}}:</label>
          <select ng-model="selectedData" ng-options="option.value as option.name for option in options">
            <option value="">-- choose {{label}} --</option>
          </select>
          <div class="propertySelect"></div>
          """
        )(insertScope, (select, childScope) ->
          childScope.htmlElement = select
          childScope.label = label
          childScope.options = options

          childScope.selectedData = snippet.model.data('dataIdentifier')
          if childScope.selectedData
            propertySelect = renderPopupPropertySelect(scope, 'Popup Property', snippet)

          childScope.$watch('selectedData', (newVal, oldVal) ->
            snippet.model.data('dataIdentifier', newVal)
            snippet.model.data('geojson', dataService.get(newVal))
            if newVal != oldVal
              snippet.model.data('popupContentProperty', null)
              scope.propertySelectElem.remove() if scope.propertySelectElem
              propertySelect = renderPopupPropertySelect(scope, 'Popup Property', snippet)
              $(".upfront-properties-form .propertySelect").append(propertySelect)
          )

          $(".upfront-properties-form").append(select)
          $(".upfront-properties-form .propertySelect").append(propertySelect)
        )


      renderData = (data, snippet) ->
        cleanForm()
        renderDataSelect('Mock Data', dataService.options(), snippet)
  }
