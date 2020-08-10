'CMM2 Turtle Graphics Demo
'Adapted from various sources on the Internet
'by "Sasquatch"

Mode 1,8

Draw(400,45.5)
Pause(10000)

Draw (500,55.5)
Pause(10000)

Draw (600,60.2)
Pause(10000)

Draw (800,89.5)
Pause(10000)

Draw (900,110)
Pause(10000)

Draw (1000,119.9)
Pause(10000)

Draw (1000,120.1)
Pause(10000)

Draw (1000,135.1)
Pause(10000)

Draw (1000,145)
Pause(10000)

Draw (1000,176)
Pause(10000)

Draw (1000,190)
Pause(10000)

End

Sub Draw(Count,Angle)

 Turtle Reset
 N = 5
 A = 90

 For I = 1 To Count
   Turtle Forward N
   A = A + Angle
   Turtle Heading A mod 360
   Turtle Pen Colour Map(I mod 255)
   N = N + 0.5
 Next I

End Sub
