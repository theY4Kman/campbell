campbell
========

A text editor easing the process of distilling idea diarrhea.

Named for "Campbell's Condensed Soup"


## The Flow Concept

When the editor is started, there's an editor on the left you can write in. It
automatically separates paragraphs by newline, so when you press Enter, a new
paragraph is created. Anything you type into a paragraph appears in gray
directly across in the right editor.

The concept is to begin by writing any thought at all that comes to mind in the
left editor. When everything is out, you read each paragraph individually in
the right editor. If you think you can write the paragraph in a better way,
you click it and begin typing. If you want to split the paragraph into several,
the paragraph text is automatically copied, so you direct the cursor to your
split points and hit Enter.

Once you've made a pass, you hit the "I'm Satisfied" button. The left editor
is wiped, and your changes replace the paragraphs they were under in the right
editor. Rinse and repeat.


## The Motivation

When I get a good idea, I just want to get it all out before I lose it, which
I'm incredibly apt to do at Mitch Hedberg proportions. I don't want to be
concerned with phrasing or niggling over little details; I just want the main
idea down, so my mind is clear to be concerned with phrasing and the deets.

Once I'm concerned with phrasing and the deets, I don't want to be worrying
about formatting or text editing, I just want to get the ideas out.

So, I designed campbell to allow for separation of concerns. Instead of
thinking about the big picture, I need only concern myself with what's in front
of me and how I can make that better or clearer. Lots of small improvements
add up, without it feeling like work has been done.

Plus, I always wanted an editor which could show how individual ideas were
developed through time. I thought it would be incredible to visually see my
thought processes without needing to consciously observe myself, which makes it
harder to concentrate on actually thinking. Campbell will be able to accomplish
this by recording a timeline of "I'm Satisfied" frames. (It doesn't do it, yet)

Additionally, while using it during development, I found myself using it as a
todo list. I would write down the high-level features, like "I'm Satisfied
button", then when it came time to develop it, I would write all the tasks
needed to accomplish that feature. In the process of performing those tasks, I
would write down concerns and things to review later. I really needed a way to
delete paragraphs, because I ended up replacing things with "done", so I'll add
that.

So, essentially, it allows me to focus all my energy on what's immediately
important, without losing any information along the way. Or, well, it will,
once I finish the fucker.
