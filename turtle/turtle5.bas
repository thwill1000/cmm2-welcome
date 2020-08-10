' Sierpinski's Triangle Recursive Fractal

Mode 1,8

Colour 0,RGB(255,255,255)

Turtle Reset
Turtle Pen Up
Turtle Move 70,575
Turtle Turn Right 90
Turtle Pen Down

Turtle Pen Colour 0

Sierpinski(650,7)

End


Sub Sierpinski(Length,Level)

 If Level = 0 Then
   For i = 1 to 3
     Turtle Forward Length
     Turtle Turn Left 120
'      Pause(50)
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
