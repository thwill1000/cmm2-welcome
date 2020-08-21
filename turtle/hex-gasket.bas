' Hex Gasket Recursive Fractal
' Author: ???

#Include "../common/common.inc"

Mode 1,8
Cls
we.clear_keyboard_buffer()

Colour 0,RGB(255,255,255)

Turtle Reset
Turtle Pen Up
Turtle Move 70,575
Turtle Turn Right 90
Turtle Pen Down
Turtle Pen Colour 0
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