' Hilbert Curve using recursion
' Author:

#Include "../common/common.inc"

Mode 1,8
Cls
we.clear_keyboard_buffer()

Dim ch$
C = 1

Turtle Reset
we.title("Hilbert Curve (1 of 2)", 1)
Turtle Pen Up
Turtle Move 20,600
Turtle Pen Down
Hilbert(7,90,6)
we.title("Hilbert Curve (1 of 2)", 1)

we.wait_for_key()
If we.quit% Then we.end_program()

Turtle Reset
we.title("Hilbert Curve (2 of 2)", 1)
Turtle Pen Up
Turtle Move 150,550
Turtle Pen Down
Hilbert(8,90,2)

we.end_program()

Sub Hilbert(Level,Angle,Length)
  If Level = 0 Then Exit Sub

  C = C + 0.1
  Turtle Pen Colour Map(C Mod 255)

  TurnTurtle(Angle)
  Hilbert(Level - 1,0 - Angle, Length)

  Turtle Forward Length
  TurnTurtle(0 - Angle)
  Hilbert(Level - 1,Angle,Length)

  Turtle Forward Length
  Hilbert(Level - 1,Angle,Length)

  TurnTurtle(0 - Angle)
  Turtle Forward Length
  Hilbert(Level - 1,0 - Angle,Length)

  TurnTurtle(Angle)
End Sub

Sub TurnTurtle(Angle)
  If Angle > 0 Then
    Turtle Turn Right Angle
  Else If Angle < 0 Then
    Turtle Turn Left Abs(Angle)
  End If
End Sub
