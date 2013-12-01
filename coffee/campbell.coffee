app = angular.module('campbell', ['LocalStorageModule'])


app.directive('hallo', ($timeout) ->
  return {
    link: (scope, element, attrs) ->
      # Ensure the main campbell app can keep an ID=>element mapping
      scope.$emit('register-element', element, scope.$eval(attrs.halloId))


      $element = $(element)

      initial_html = scope.$eval(attrs.halloText)
      # Ensure *some* HTML is in the element, otherwise hallo will add a
      # min-width, which generally isn't correct after HTML is entered.
      element.html(if initial_html.length > 0 then initial_html else '&nbsp;')
      $element.hallo()

      scope.$watch(attrs.halloText, ->
        $element.html(scope.$eval(attrs.halloText))
      )

      # THIS IS A jQuery EVENT, NOT AN ANGULAR EVENT
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
          scope.$emit('hallo-split', element, scope.$eval(attrs.halloId), after)

        scope.$emit('hallo-modified', element)

        escaped = content.replace('"', '\\"')
        scope.$eval(attrs.halloText + ' = "' + escaped + '"')
        scope.$apply()
      )


      scope.selectAll = ->
        $timeout(->
          replacement = element[0]
          if window.getSelection and document.createRange
            range = document.createRange()
            range.selectNodeContents(replacement)
            sel = window.getSelection()
            sel.removeAllRanges()
            sel.addRange(range)
          else if document.body.createTextRange
            range = document.body.createTextRange()
            range.moveToElementText(replacement)
            range.select()
        1);

      # Focus new hallos
      $element.focus()
  }
)


app.directive('distilledInitial', ->
  {
    link: (scope, element, attrs) ->
      scope.$watch(attrs.ngModel, ->
        element.html(scope.$eval(attrs.ngModel))
      )

      element.on('click', ->
        scope.$emit('distilled-initial-click')
      )
  }
)


app.directive('distilledBlock', ($rootScope) ->
  {
    link: (scope, element, attrs) ->
      scope.height = -> $(element).height()

      scope.$on('hallo-modified', (evt, element) ->
        $rootScope.$broadcast('distilled-modified', scope)
      )

      # Drawing attention to 3rd parameter: because block.replacements is an
      # array, it is stored as a reference, so testing equality without using
      # angular.equals (which does deep testing) always returns true, unless a
      # new array is created.
      scope.$watch('block.replacements', ->
        $rootScope.$broadcast('distilled-modified', scope)
      true)

      scope.$on('distilled-initial-click', ->
        $replacements = $(element).find('.replacements > p')
        if $replacements.length
          $selected = $replacements.first()
          $selected.focus()
          # XXX: is this more useful than putting focus at end of block? I
          #      would want to impose using the Satisfaction button, but it may
          #      actually be more convenient to be able to easily remove all
          #      text of an item, thereby allowing the user to attempt (and
          #      possibly succeed) at offering a better idea by niggling in the
          #      distillation editor, while still allowing distinct
          #      distillation by Satisfaction for other users. Totes keeping
          #      it.
          # FIXME: move discussion to a GH issue and replace with link next ci
          angular.element($selected).scope().selectAll()
        else
          replacement = scope.newReplacement(scope.block.text)
          scope.insertReplacementAfter(replacement, scope.block)
          scope.$apply()

          repl_element = scope.getElementById(replacement.id)
          repl_element.scope().selectAll()
      )


      $rootScope.$broadcast('distilled-created', scope)
  }
)


app.controller('CampbellCtrl', ($scope) ->
  $scope.blocks = []
  $scope.nodes_by_id = {}

  paragraph_counter = 0
  $scope.nextId = -> paragraph_counter++


  $scope.newReplacement = (text='') -> {id: $scope.nextId(), text: text}
  $scope.newBlock = (text='', replacements=[]) ->
    {
      id: $scope.nextId(),
      text: text,
      replacements: $scope.newReplacement(text) for text in replacements
    }


  $scope.insertBlockAfter = (block, id) ->
    $scope.nodes_by_id[block.id] = block
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


  $scope.getElementById = (id) ->
    $scope.nodes_by_id[id]


  $scope.$on('register-element', (evt, element, id) ->
    $scope.nodes_by_id[id] = element
  )


  # Create initial block
  $scope.insertBlockAfter($scope.newBlock('Edit me', ['Edit me, too']))
)


app.controller('InitialCtrl', ($scope, $timeout) ->
  $scope.getElementOfBlock = (id) ->
    document.querySelector('#initial' + id)


  $scope.$on('hallo-split', (evt, element, id, text) ->
    block = $scope.newBlock(text)
    $scope.insertBlockAfter(block, id)
  )


  matchDistilledHeight = (evt, distilled) ->
    $timeout(->
      $paragraph = $($scope.getElementOfBlock(distilled.block.id))
      $paragraph.height(distilled.height())
    )

  $scope.$on('distilled-modified', matchDistilledHeight)
  $scope.$on('distilled-created', matchDistilledHeight)
)


app.controller('ReplacementsCtrl', ($scope) ->
  $scope.$on('hallo-split', (evt, element, id, text) ->
    replacement = $scope.newReplacement(text)
    $scope.insertReplacementAfter(replacement, $scope.block, id)
  )
)


app.controller('DistilledCtrl', ($scope, $rootScope) ->

)
