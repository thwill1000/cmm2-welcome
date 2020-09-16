' Sierpinski Triangle Recursive Fractal
' Author: "Sasquatch"

#Include "../common/welcome.inc"

Mode 1,8
Cls
we.clear_keyboard_buffer()

Text 0, 0, "Sierpinski Triangle", "", 2
Text 2, 25, "Press Q to Quit", "", 1

Turtle Pen Up
Turtle Move 70,575
Turtle Turn Right 90
Turtle Pen Down
Sierpinski(650,7)

we.wait_for_quit()
we.end_program()

Sub Sierpinski(Length,Level)

  If Level = 0 Then
    For i = 1 to 3
      Turtle Forward Length
      Turtle Turn Left 120
    Next i
    Exit Sub
  EndIf

  Sierpinski(Length / 2.0, Level - 1)
  Turtle Pen Up
  Turtle Forward Length / 2.0
  Turtle Pen Down

  Sierpinski(Length / 2.0, Level - 1)
  Turtle Pen Up
  Turtle Turn Left 120
  Turtle Forward Length / 2.0
  Turtle Turn Right 120
  Turtle Pen Down

  Sierpinski(Length / 2.0, Level - 1)
  Turtle Pen Up
  Turtle Turn Left 60
  Turtle Backward Length / 2.0
  Turtle Turn Right 60
  Turtle Pen Down

End Sub
