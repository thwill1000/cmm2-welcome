' Barnsley's Fern
' Author: "Sasquatch"

#Include "../common/welcome.inc"

Mode 1,8
Cls
we.clear_keyboard_buffer()

Text 0, 0, "Barnsley's Fern", "", 2
Text 2, 25, "Press Q to Quit", "", 1

Const GREEN = RGB(0,100,0)

For i = 1 to 1000000

  Select Case Rnd()
    Case IS < .01
      NextX = 0
      NextY = 0.16 * Y
    Case .01 TO .08
      NextX = .2 * X - .26 * Y
      NextY = .23 * X + .22 * Y + 1.6
    Case .08 TO .15
      NextX = -.15 * X + .28 * Y
      NextY = .26 * X + .24 * Y + .44
    Case Else
      NextX = .85 * X + .04 * Y
      NextY = -.04 * X + .85 * Y + 1.6
  End Select

  X = NextX
  Y = NextY

  Pixel X * 100 + 400, 600 - Y * 55, GREEN

  If we.is_quit_pressed%() Then Exit For

Next i

we.wait_for_quit()
we.end_program()
