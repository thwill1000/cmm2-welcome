' CMM2 Turtle Graphics Demo
' Author: "Sasquatch"
' Adapted from various sources on the Internet
' Adapted for CMM2 "Welcome Tape" by "thwill"

Option Base 1
Option Explicit
Option Default None

#Include "../common/common.inc"

Mode 1,8
Cls
we.clear_keyboard_buffer()

Dim count%(11) = (400, 500, 600, 800, 900, 1000, 1000, 1000, 1000, 1000, 1000)
Dim angle!(11) = (45.5, 55.5, 60.2, 89.5, 110, 119.9, 120.1, 135.1, 145, 176, 190)
Dim ch$, i%

For i% = 1 To 11
  Draw(count%(i%), angle!(i%))
  we.clear_keyboard_buffer()
  Do
    ch$ = Inkey$
    If ch$ <> "" Then Exit Do
  Loop
  If LCase$(ch$) = "q" Then Exit For
Next i%

we.quit% = 1
we.end_program()

Sub Draw(count%, angle!)
  Local n! = 5
  Local a! = 90

  Turtle Reset
  Text 0, 0, "Turtle Patterns", "", 2
  Text 2, 25, "Press Q to Quit, or any other key for the next pattern", "", 1

  Local j%
  For j% = 1 To count%
    Turtle Forward n!
    a! = a! + angle!
    Turtle Heading a! mod 360
    Turtle Pen Colour Map(j% mod 255)
    n! = n! + 0.5
  Next j%

End Sub
