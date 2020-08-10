' Random Recursive Fractal Pine Trees

Mode 1,8

Turtle Reset
Turtle Pen Up
Turtle Move 400,500
Turtle Pen Down

PineTree(100,19)

End


Sub PineTree(Length,Depth)
 If Depth <= 0 Then Exit Sub
 
 Local Angle = 110 + 20 * Rnd()

 If Length > 5 Then
   Turtle Pen Colour RGB(139,69,19)  'Make the sticks brown
 Else
   Turtle Pen Colour RGB(0,100,0)  'Make the needles Green
 EndIf

 Turtle Forward Length
 PineTree(Length * 0.8, Depth - 1)
 Turtle Turn Right Angle
 PineTree(Length * 0.5, Depth - 3)
 Turtle Turn Right 120
 PineTree(Length * 0.5, Depth - 3)
 Turtle Turn Right 240 - Angle
 Turtle Pen Up
 Turtle Backward Length  
 Turtle Pen Down

End Sub
