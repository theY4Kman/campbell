paragraph_counter = 0
initial_id_prefix = 'initial'

$distilled_editor = null
$initial_editor = null

# Saves state at each moment of satisfaction
timeline = [null]


recordCurrentState = ->
  timeline[timeline.length - 1] = [Date.now(), reprState()]


changeOccurred = ->
  recordCurrentState()
  localStorage.timeline = timeline


newInitialParagraph = (text) ->
  $initial = $('<p>')
  $initial.hallo()
  $initial.html(text)
  $initial.on('hallomodified', initialModified)
  $initial.attr('id', initial_id_prefix + paragraph_counter)
  paragraph_counter += 1

  newDistilledParagraph($initial)
  resizeInitial($initial)

  $initial


newDistilledParagraph = ($initial) ->
  $distilled = $('<p>')
  $distilled.addClass('initial')
  $distilled.attr('id', 'distilled' + $initial.attr('id').substr(initial_id_prefix.length))
  $distilled.html($initial.html())

  $container = $('<div>')
  $container.data('initial', $initial)
  $container.append($distilled)
  $initial.data('distilled', $container)
  $initial.data('distilled-initial', $distilled)

  $distilled.on('click', ->
    $this = $(this)
    $next = $this.next()
    $replacement = if $next.is('.replacement') then $next
    if not $replacement?
      $replacement = newReplacementParagraph($container)
      $this.after($replacement)
    $replacement.focus()

    resizeInitial($initial)
  )

  $previous = $initial.prev()
  if $previous.length
    $previous.data('distilled').after($container)
  else
    $distilled_editor.append($container)


newReplacementParagraph = ($distilled) ->
  $replacement = $('<p>')
  $replacement.addClass('replacement')
  $replacement.hallo()
  $replacement.data('distilled', $distilled)
  $replacement.on('hallomodified', replacementModified)

  $replacement


replacementModified = (evt, hallo_evt) ->
  $this = $(this)

  # This is checking for a newline, which might not be cross-browser compatible
  # FIXME This should probably be done in a keypress or similar event.
  # XXX This could be a hallo-controlled thing, and there may be nothing to worry about.
  newline_html_content = '<div>'
  newline_idx = hallo_evt.content.indexOf(newline_html_content)
  if newline_idx >= 0
    before = hallo_evt.content.substring(0, newline_idx)
    after = $this.find('div').text()

    $this.html(before)
    $p = newReplacementParagraph($this.data('distilled'))
    $p.html(after)
    $this.after($p)
    $p.focus()

  resizeInitial($this.data('distilled').data('initial'))
  changeOccurred()


initialModified = (evt, hallo_evt) ->
  $this = $(this)

  # This is checking for a newline, which might not be cross-browser compatible
  # FIXME This should probably be done in a keypress or similar event.
  newline_html_content = '<div>'
  newline_idx = hallo_evt.content.indexOf(newline_html_content)
  if newline_idx >= 0
    before = hallo_evt.content.substring(0, newline_idx)
    after = $this.find('div').text()

    $this.html(before)
    $p = newInitialParagraph(after)
    $this.after($p)
    $p.focus()

  $this.data('distilled-initial').html($this.html())
  resizeInitial($this)
  changeOccurred()


imSatisfied = ->
  $initial_editor.empty()

  $containers = $distilled_editor.children()
  $containers.remove()
  $containers.each(->
    $this = $(this)
    $replacements = $this.children('.replacement')

    replacements = []
    # Empty replacements are considered nonexistent
    $replacements.each(->
      text = $(this).html()
      if text
        replacements.push(text)
    )

    if replacements.length == 0
      initial_text = $this.children('.initial').html()
      if initial_text
        $initial = newInitialParagraph(initial_text)
        $initial_editor.append($initial)
    else
      $.each(replacements, ->
        $initial = newInitialParagraph(this)
        $initial_editor.append($initial)
      )
  )

  if $initial_editor.children().length == 0
    newInitialParagraph().appendTo($initial_editor)


# Resize the initial paragraph to match height of distilled
resizeInitial = ($initial) ->
  $distilled_container = $initial.data('distilled')
  $initial.height($distilled_container.height())


reprState = ->
  # All that's needed to reproduce state at one point is the distilled side's
  # initial text, its replacements (if they exist), and the ordering of the
  # paragraphs (done with a list).
  # TODO When removal of paragraphs is added, an is_removed flag will have to
  #      be added

  paragraphs = []
  $distilled_editor.children().each(->
    $this = $(this)
    initial = $this.data('distilled-initial').text()

    replacements = []
    $this.find('.replacement').each(->
      replacements.push($(this).text())
    )

    paragraphs.push([initial, replacements])
  )

  paragraphs


$ ->
  $distilled_editor = $('#distilled')
  $initial_editor = $('#initial')

  newInitialParagraph().appendTo($initial_editor)

  # Replace the placeholder null with an actual state repr. Not necessary, but
  # ensures timeline contains only valid state reprs when the application is
  # active, so potential future features can assume this is so.
  timeline = [reprState()]

  $('#satisfied').click(imSatisfied)

