' Square Nautilus
' Author: "Sasquatch"

#Include "../common/welcome.inc"

Mode 1,8
Cls
we.clear_keyboard_buffer()

Text 0, 0, "Square Nautilus", "", 2
Text 2, 25, "Press Q to Quit", "", 1

Size = 275
N = 100
Angle = 10
Ratio = 0.97

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

we.wait_for_quit()
we.end_program()
