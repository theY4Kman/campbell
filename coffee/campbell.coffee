app = angular.module('campbell', ['LocalStorageModule'])


app.directive('hallo', ->
  return {
    link: (scope, element, attrs) ->
      $element = $(element)

      initial_html = scope.$eval(attrs.halloText)
      # Ensure *some* HTML is in the element, otherwise hallo will add a
      # min-width, which generally isn't correct after HTML is entered.
      element.html(if initial_html.length > 0 then initial_html else '&nbsp;')
      $element.hallo()

      scope.$watch(attrs.halloText, ->
        $element.html(scope.$eval(attrs.halloText))
      )

      $element.on('hallomodified', ->
        content = element.html()

        newline_idx = content.indexOf('<div>')
        if newline_idx >= 0
          before = content = content.substring(0, newline_idx)
          # When the text input is '\ntext here', the resulting HTML is
          # '<div><br></div>', so the after text is actually the last text node
          child_nodes = element[0].childNodes
          last_node = child_nodes[child_nodes.length - 1]
          after_div_text = if last_node.nodeType == 3 then last_node.nodeValue else ''
          after = element.find('div').text() + after_div_text

          element.html(before)
          scope.$emit('hallosplit', element, scope.$eval(attrs.halloId), after)

        scope.$emit('hallomodified', element)

        escaped = content.replace('"', '\\"')
        scope.$eval(attrs.halloText + ' = "' + escaped + '"')
        scope.$apply()
      )

      # Focus new hallos
      $element.focus()
  }
)


app.directive('distilledInitial', ->
  return {
    link: (scope, element, attrs) ->
      scope.$watch(attrs.ngModel, ->
        element.html(scope.$eval(attrs.ngModel))
      )

      element.on('click', ->
        scope.$emit('distilledinitialclick')
      )
  }
)


app.directive('distilledBlock', ($rootScope) ->
  return {
    link: (scope, element, attrs) ->
      scope.height = -> $(element).height()

      scope.$on('hallomodified', (evt, element) ->
        $rootScope.$broadcast('distilledmodified', scope)
      )

      # Drawing attention to 3rd parameter: because block.replacements is an
      # array, it is stored as a reference, so testing equality without using
      # angular.equals (which does deep testing) always returns true, unless a
      # new array is created.
      scope.$watch('block.replacements', ->
        $rootScope.$broadcast('distilledmodified', scope)
      true)

      scope.$on('distilledinitialclick', ->
        $replacements = $(element).find('.replacements > p')
        if $replacements.length
          $replacements.first().focus()
        else
          replacement = scope.newReplacement()
          scope.insertReplacementAfter(replacement, scope.block)
          scope.$apply()
      )


      $rootScope.$broadcast('distilledcreated', scope)
  }
)


app.controller('CampbellCtrl', ($scope) ->
  $scope.blocks = []

  paragraph_counter = 0
  $scope.nextId = -> paragraph_counter++


  $scope.newReplacement = (text='') -> {id: $scope.nextId(), text: text}
  $scope.newBlock = (initial='', replacements=[]) ->
    {
      id: $scope.nextId(),
      initial: initial,
      replacements: $scope.newReplacement(text) for text in replacements
    }


  $scope.insertBlockAfter = (block, id) ->
    if id?
      for cur_block, i in $scope.blocks
        if cur_block.id == id
          $scope.blocks.splice(i + 1, 0, block)
          break
    else
      $scope.blocks.push(block)


  $scope.insertReplacementAfter = (replacement, block, id) ->
    if id?
      for cur_replacement, i in block.replacements
        if cur_replacement.id == id
          block.replacements.splice(i + 1, 0, replacement)
          break
    else
      block.replacements.push(replacement)


  # Create initial block
  $scope.insertBlockAfter($scope.newBlock('Edit me', ['Edit me, too']))
)


app.controller('InitialCtrl', ($scope, $timeout) ->
  $scope.getElementOfBlock = (id) ->
    document.querySelector('#initial' + id)


  $scope.$on('hallosplit', (evt, element, id, text) ->
    block = $scope.newBlock(text)
    $scope.insertBlockAfter(block, id)
  )


  matchDistilledHeight = (evt, distilled) ->
    $timeout(->
      $paragraph = $($scope.getElementOfBlock(distilled.block.id))
      $paragraph.height(distilled.height())
    )

  $scope.$on('distilledmodified', matchDistilledHeight)
  $scope.$on('distilledcreated', matchDistilledHeight)
)


app.controller('ReplacementsCtrl', ($scope) ->
  $scope.$on('hallosplit', (evt, element, id, text) ->
    replacement = $scope.newReplacement(text)
    $scope.insertReplacementAfter(replacement, $scope.block, id)
  )
)


app.controller('DistilledCtrl', ($scope, $rootScope) ->

)
