' Hex Gasket Recursive Fractal
' Author: "capsikin"

#Include "../common/welcome.inc"

Mode 1,8
Cls
we.clear_keyboard_buffer()

Text 0, 0, "Hex Gasket Fractal", "", 2
Text 2, 25, "Press Q to Quit", "", 1

Turtle Pen Up
Turtle Move 70,400
Turtle Turn Right 90
Turtle Pen Down
Gasket(650,10)

we.wait_for_quit()
we.end_program()

Sub Gasket(Length,Level)

  If we.is_quit_pressed%() Then Exit Sub

  If Level = 0 Then
    Turtle Forward Length
    Turtle Pen Up
    Turtle Backward Length
    Turtle Pen Down
    Exit Sub
  EndIf

  Turtle Turn Left 60

  Turtle Pen Up
  Turtle Forward Length/2
  Turtle Pen Down
  Turtle Turn Right 180
  Gasket(Length / 2.0, Level - 1)
  Turtle Turn Left 180

  Turtle Turn Right 60

  Turtle Pen Up
  Turtle Forward Length/2
  Turtle Pen Down
  Turtle Turn Right 180
  Gasket(Length / 2.0, Level - 1)
  Turtle Turn Left 180

  Turtle Turn Right 60

  Turtle Pen Up
  Turtle Forward Length/2
  Turtle Pen Down
  Turtle Turn Right 180
  Gasket(Length / 2.0, Level - 1)
  Turtle Turn Left 180

  Turtle Pen Up

  Turtle Turn Right 180
  Turtle Forward Length/2

  Turtle Turn Left 60
  Turtle Forward Length/2

  Turtle Turn Left 60
  Turtle Forward Length/2

  Turtle Turn Right 60
  Turtle Turn Right 180

  Turtle Pen Down

End Sub
End Sub
