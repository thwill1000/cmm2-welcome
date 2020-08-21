' Hex Gasket Recursive Fractal
' Author: ???

#Include "../common/common.inc"

Mode 1,8
Cls
we.clear_keyboard_buffer()

Text 0, 0, "Hex Gasket Recursive Fractal", "", 2
Text 2, 25, "Press Q to Quit", "", 1

Turtle Pen Up
Turtle Move 70,400
Turtle Turn Right 90
Turtle Pen Down
Gasket(650,5)

we.end_program()

Sub Gasket(Length,Level)

  If Level = 0 Then
    Turtle Forward Length
    Exit Sub
  EndIf

  Turtle Pen Up
  Turtle Forward Length
  Turtle Pen Down
  Turtle Turn Left 120
  Gasket(Length / 2.0, Level - 1)
  Turtle Turn Left 60
  Gasket(Length / 2.0, Level - 1)
  Turtle Turn Left 60
  Gasket(Length / 2.0, Level - 1)
  Turtle Turn Left 120
  Turtle Pen Up
  Turtle Forward Length
  Turtle Pen Down

End Sub
