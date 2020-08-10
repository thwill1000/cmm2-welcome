' Hex Gasket Recursive Fractal

Mode 1,8

Colour 0,RGB(255,255,255)

Turtle Reset
Turtle Pen Up
Turtle Move 70,575
Turtle Turn Right 90
Turtle Pen Down

Turtle Pen Colour 0

'Gasket(650,7)

Gasket(650,5)

End


Sub Gasket(Length,Level)

If Level = 0 Then
  Turtle Forward Length
'   Pause(50)
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