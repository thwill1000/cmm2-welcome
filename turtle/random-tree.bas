' Random Recursive Fractal Tree
' Author: "Sasquatch"

#Include "../common/welcome.inc"

Mode 1,8
Cls
we.clear_keyboard_buffer()

Text 0, 0, "Random Recursive Fractal Tree", "", 2
Text 2, 25, "Press Q to Quit", "", 1

Turtle Pen Up
Turtle Move 400,600
Turtle Pen Down

For X = 1 to 5
  Tree(100)
  Pause(1000)
  If we.is_quit_pressed%() Then Exit For
Next X

we.wait_for_quit()
we.end_program()

Sub Tree(Length)
  If Length < 1 Then Exit Sub

  Local RndLength = Length + Rnd * 5
  Local RndAngle = 15 + Int(Rnd * 20.0)

  If RndLength > 20 Then
    Turtle Pen Colour RGB(139,69,19)
  Else
    Turtle Pen Colour RGB(34,139,34)
  EndIf

  Turtle Pen Down
  Turtle Forward RndLength
  Turtle Turn Right RndAngle
  Tree(RndLength - 15)
  Turtle Turn Left RndAngle * 2
  Tree(RndLength - 15)
  Turtle Pen UP
  Turtle Turn Right RndAngle
  Turtle Backward RndLength

End Sub
