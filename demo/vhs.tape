# ayu-dusk: the six generated snippets of demo/snippets in a bare Emacs, with the
# theme loaded from this checkout.  C-n walks through the snippets and the cursor
# is moved over the middle of each file, which is what lights up the current line
# number.
#
# Nothing here paints anything: no Set Theme, no margin, no colours of its own.
# What is recorded is the grid Emacs drew, so every colour is one the palette
# under test put there.
#
# The last C-n wraps back to the first snippet: the GIF loops there and that is
# what the screenshot captures.  The pause before the Screenshot is deliberate --
# vhs writes it from the frames the recorder has already produced, so it shows
# the screen of a couple of seconds earlier, and it needs a command after it to
# be written at all.

Set Shell "bash"
Set FontFamily "Maple Mono NF"
Set FontSize 16
Set LineHeight 1.2
Set Padding 5
Set Margin 0
Set Width 915
Set Height 900
Set Framerate 30
Set TypingSpeed 20ms
Set CursorBlink false

Output demo/output/output.gif

Require emacs

# Wait for the whole screen, and do not hide the launch: vhs matches only the
# last line without `+Screen' (which fires almost at once, so the keys land
# while Emacs is still starting up), and with `Hide' the recorder stops updating
# its canvas and the whole recording freezes on the first frame.
#
# The harness is loaded with `inhibit-message' bound: Emacs prints the
# "Loading demo/init.el..." banner before the file is evaluated, so the file
# itself cannot silence that one, and it would stay in the echo area for the
# rest of the recording.  Everything after the load is silenced by the file.
Type `clear; emacsclient -c -e '(let ((inhibit-message t)) (load "demo/init.el"))'`
Enter
Wait+Screen@20s /Package summer/
Sleep 500ms

# the first snippet, with the cursor walked over the middle of the file
Down 15
Sleep 900ms
Up 5
Sleep 700ms
Down 8
Sleep 900ms

# every other snippet is one C-n away
Ctrl+N
Sleep 800ms
Down 15
Sleep 900ms
Up 5
Sleep 700ms
Down 8
Sleep 900ms
Ctrl+N
Sleep 800ms
Down 15
Sleep 900ms
Up 5
Sleep 700ms
Down 8
Sleep 900ms
Ctrl+N
Sleep 800ms
Down 15
Sleep 900ms
Up 5
Sleep 700ms
Down 8
Sleep 900ms
Ctrl+N
Sleep 800ms
Down 15
Sleep 900ms

Up 5
Sleep 700ms
Down 8
Sleep 900ms
Ctrl+N
Sleep 800ms
Down 15
Sleep 900ms
Up 5
Sleep 700ms
Down 8
Sleep 900ms

# back to the first snippet, held still long enough for the screenshot
Ctrl+N
Sleep 800ms
Down 15
Sleep 900ms
Up 5
Sleep 700ms
Down 8
Sleep 900ms
Sleep 3s
Screenshot demo/output/screenshot.png
Sleep 1s
