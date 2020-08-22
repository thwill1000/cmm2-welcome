' Recursive Fractal Pine Tree
' Author: ???

#Include "../common/common.inc"

Mode 1,8
Cls
we.clear_keyboard_buffer()

Text 0, 0, "Recursive Fractal Pine Tree", "", 2
Text 2, 25, "Press Q to Quit", "", 1

Turtle Pen Up
Turtle Move 400,500
Turtle Pen Down
PineTree(100,20)

we.end_program()

Sub PineTree(Length,Depth)
  If we.is_quit_pressed%() Then Exit Sub
  If Depth <= 0 Then Exit Sub

  If Length > 2 Then
    Turtle Pen Colour RGB(139,69,19)  'Make the sticks brown
  Else
    Turtle Pen Colour RGB(0,100,0)  'Make the needles Green
  EndIf

  Turtle Forward Length
  PineTree(Length * 0.8, Depth - 1)
  Turtle Turn Right 120
  PineTree(Length * 0.5, Depth - 3)
  Turtle Turn Right 120
  PineTree(Length * 0.5, Depth - 3)
  Turtle Turn Right 120
  Turtle Pen Up
  Turtle Backward Length
  Turtle Pen Down

End Sub
