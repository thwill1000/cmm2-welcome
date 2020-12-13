' CMM2 Turtle Graphics Demo
' Author: "Sasquatch"
' Adapted from various sources on the Internet

Option Base 1
Option Explicit
Option Default None

#Include "../common/welcome.inc"

Mode 1,8
Cls

Dim count%(11) = (400, 500, 600, 800, 900, 1000, 1000, 1000, 1000, 1000, 1000)
Dim angle!(11) = (45.5, 55.5, 60.2, 89.5, 110, 119.9, 120.1, 135.1, 145, 176, 190)
Dim i%, s$

For i% = 1 To 11
  Turtle Reset
  s$ = "Spirals (" + Str$(i%) + " of 11)"
  Text 0, 0, s$, "", 2
  s$ = "Press Q for Quit"
  If i% < 11 Then s$ = s$ + ", or any other key for the next pattern"
  Text 2, 25, s$, "", 1

  Draw(count%(i%), angle!(i%))

  we.clear_keyboard_buffer()
  s$ = we.wait_for_key$()
  If we.is_quit_key%(s$) Then Exit For
Next i%

we.wait_for_quit()
we.end_program()

Sub Draw(count%, angle!)
  Local n! = 5
  Local a! = 90
  Local j%

  For j% = 1 To count%
    Turtle Forward n!
    a! = a! + angle!
    Turtle Heading a! mod 360
    Turtle Pen Colour Map(j% mod 255)
    n! = n! + 0.5
  Next j%

End Sub
