' Hilbert Curve using recursion
' Author: "Sasquatch"

#Include "../common/welcome.inc"

Mode 1,8

Dim k$
C = 1

we.clear_keyboard_buffer()
Turtle Reset
Text 0, 0, "Hilbert Curve (1 of 2)", "", 2
Text 2, 25, "Press Q to Quit, or any other key for the next pattern", "", 1
Turtle Pen Up
Turtle Move 20,600
Turtle Pen Down
Hilbert(7,90,6)
Text 0, 0, "Hilbert Curve (1 of 2)", "", 2
Text 2, 25, "Press Q to Quit, or any other key for the next pattern", "", 1

If k$ = "" Then k$ = we.wait_for_key$()
If we.is_quit_key%(k$) Then we.end_program()

k$ = ""
we.clear_keyboard_buffer()
Turtle Reset
Text 0, 0, "Hilbert Curve (2 of 2)", "", 2
Text 2, 25, "Press Q to Quit", "", 1
Turtle Pen Up
Turtle Move 150,550
Turtle Pen Down
Hilbert(8,90,2)

If Not we.is_quit_key%(k$) Then we.wait_for_quit()
we.end_program()

Sub Hilbert(Level,Angle,Length)
  If k$ = "" Then k$ = Inkey$
  If k$ <> "" Then Exit Sub

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
