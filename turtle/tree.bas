' Recursive Fractal Tree
' Author: "Sasquatch"

#Include "../common/welcome.inc"

Mode 1,8
Cls
we.clear_keyboard_buffer()

Text 0, 0, "Recursive Fractal Tree", "", 2
Text 2, 25, "Press Q to Quit", "", 1

Turtle Pen Up
Turtle Move 400,600
Turtle Pen Down
Tree(120)

we.wait_for_quit()
we.end_program()

Sub Tree(Length)
  If Length < 1 Then Exit Sub

  If Length > 20 Then
    Turtle Pen Colour RGB(139,69,19)
  Else
    Turtle Pen Colour RGB(34,139,34)
  EndIf

  Turtle Pen Down
  Turtle Forward Length
  Turtle Turn Right 20
  Tree(Length - 15)
  Turtle Turn Left 40
  Tree(Length - 15)
  Turtle Pen UP
  Turtle Turn Right 20
  Turtle Backward Length

End Sub
