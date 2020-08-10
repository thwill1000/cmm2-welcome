' Recursive Fractal Trees

Mode 1,8


Turtle Reset
Turtle Pen Up
Turtle Move 400,600
Turtle Pen Down

Tree(120)

End


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
