' Square Nautilus Turtle Graphics Demo

Mode 1,8

Size = 275
N = 100
Angle = 10
Ratio = 0.97

Turtle Reset

For i = 1 to N
 
 'Draw a square
 For j = 1 to 4
   Turtle Forward Size
   Turtle Turn Left 90
 Next j

 'Rinse and Repeat
 Turtle Turn Left Angle
 Size = Size * Ratio

Next i

End
