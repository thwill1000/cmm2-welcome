' Sprite Demo Program for the Colour Maximite 2
' written by vegipete, October 2, 2020
'
' An example of throwing sprites around on the screen, in particular
' showing how to hide them in the reverse order they were drawn.

Sub splash()
  Local i, j, posn
  Local coords(12, 3)

  show_serial_splash()

  ' read in the home possition for each sprite
  for i = 0 to 12
    read coords(i,0), coords(i,1)
  next i

  ' load and prepare graphics
  page write 2
  cls_vga()
  load png WE.PROG_DIR$ + "/logo-large.png"  ' this was saved as a 32 bit PNG

  ' Colour number 0 is always transparent for sprites
  ' As a result, we can't use colour number 0 if we want a sprite
  ' to contain black pixels. Instead, a dark grey is chosen to
  ' substitute for black. If we peek into image memory at a
  ' location known to contain our dark gray colour, we can determine
  ' the colour number of this dark gray. This particular colour
  ' can then be changed to true black using the colour map.
  '
  ' For the above image, location 0,200 is known to be dark gray.
  '
  Const fake_black = peek(byte MM.INFO(PAGE ADDRESS 2) + 200 * MM.HRES)
  map(fake_black) = 0
  map set

  ' Extract each sprite from the png image that was loaded on page 2
  ' The coordinates and size of each sprite were determined after the
  ' image was generated using "paint.net" on a Windoze pc.
  ' Note that sprites 5 and 9 (and 8 and 10) use the same source image
  ' but are seperate sprites so that they can be aniumated independently.
  ' Type "page copy 2,0" from the command line after this program ends
  ' to view the source image
  sprite read  1,  0,  0,125,128,2  ' red swatch
  sprite read  2,125,  0,125,128,2  ' green swatch
  sprite read  3,250,  0,125,128,2  ' blue swatch
  sprite read  4,375,  0,125,128,2  ' yellow swatch

  sprite read  5,  0,128, 82, 90,2  ' M
  sprite read  6, 89,128, 48, 90,2  ' a
  sprite read  7,255,128, 50, 90,2  ' x
  sprite read  8,178,128, 20, 90,2  ' i
  sprite read  9,  0,128, 82, 90,2  ' M
  sprite read 10,178,128, 20, 90,2  ' i
  sprite read 11,202,128, 48, 90,2  ' t
  sprite read 12,138,128, 36, 90,2  ' e
  sprite read 13,321,128, 78,100,2  ' 2

  ' Use page 1 as the working page.
  ' All drawing is performed on page 1. When each image is complete,
  ' page 1 is copied to page 0 for viewing.
  page write 1
  cls_vga()

  we.clear_keyboard_buffer();

  ' paint the coloured swatches, one by one
  Const PAINT_SPEED = 0
  Local colours(3) = (RGB(RED), RGB(GREEN), RGB(BLUE), RGB(YELLOW))
  For i = 0 To 3
    PaintStrip(i, colours(i), PAINT_SPEED, coords())
    If Inkey$ <> "" Then Exit Sub
  Next i

  cls_vga() ' erase page, show sprite version of swatches instead
  DrawSwatches(0, coords())
  page copy 1,0

  ' draw the letters, sliding in from the right
  for i = 4 to 12
    for j = MM.HRES-1 to coords(i,0) step -10
      sprite show i+1, j, coords(i,1) + 10, 1
      page copy 1,0,B   ' wait for vertical blanking before copying page
    next j
    sprite show i+1, coords(i,0), coords(i,1) + 10, 1 ' make sure sprite is in right place
    If Inkey$ <> "" Then Exit Sub
  next i

  Text 400, 265, "WELCOME TAPE", "C", 3, 1, RGB(WHITE)
  Text 400, 290, WE.VERSION$, "C", 1, 1, RGB(WHITE)
  Text 400, 570, "Press any key to go to the menu", "C", 2

  Option Console Both
  we.clear_keyboard_buffer()

  Do

    ' Animate the colour swatches.
    ' Because they are behind the letters and each other,
    ' all sprites must be hidden first.
    posn = 0
    Do
      ' Hide each sprite in the reverse order they were drawn
      for i = 13 to 1 step -1
        sprite hide i
      next i

      DrawSwatches(posn, coords())
      DrawLetters(coords())

      page copy 1,0,B

      posn = posn + .1

    Loop until posn > pi

    ' Hide everything once more to prepare for final draw before quit.
    ' The final draw ensures the swatches are place correctly because the
    ' function used to spread them apart likely didn't return to exactly 0.
    for i = 13 to 1 step -1
      sprite hide i
    next i

    ' Redraw swatches in their home position
    DrawSwatches(0, coords())
    DrawLetters(coords())

    page copy 1,0,B

    Pause 500

  Loop Until Inkey$ <> ""

End Sub

Sub show_serial_splash()
  Option Console Serial
  Cls
  print_centered("Colour Maximite 2 " + Chr$(34) + "WELCOME TAPE" + Chr$(34))
  print_centered(we.VERSION$)
  Print
  print_centered("Most programs require a VGA display")
  print_centered("Some programs also require a USB keyboard")
  Print
  print_centered("Press any key to go to the menu")
  Option Console Both
End Sub

Sub cls_vga()
  Option Console Screen
  Cls
  Option Console Both
End Sub

' Paint a coloured strip
sub PaintStrip(num, col, speed, coords())
  local i,x

  for i = 0 to 127
    x = coords(num,0) + 64 - i/2
    line x, coords(num,1) + i, x + 59, coords(num,1) + i,1, col
    page copy 1,0
    pause speed
  next i

end sub

' Draw the swatches, shifted sideways if requested
sub DrawSwatches(shift, coords())
  sprite show 1, coords(0,0) - 120 * sin(shift), coords(0,1), 1
  sprite show 2, coords(1,0) -  40 * sin(shift), coords(1,1), 1
  sprite show 3, coords(2,0) +  40 * sin(shift), coords(2,1), 1
  sprite show 4, coords(3,0) + 120 * sin(shift), coords(3,1), 1
end sub

' Draw the letters over top of the swatches
sub DrawLetters(coords())
  local i
  for i = 4 to 12
    sprite show i+1, coords(i,0), coords(i,1) + 10, 1
  next i
end sub

' locations for each sprite
data 248,125    ' red
data 308,125    ' green
data 368,125    ' blue
data 428,125    ' yellow

data 155,125    ' M
data 240,125    ' a
data 291,125    ' x
data 344,125    ' i
data 367,125    ' M
data 452,125    ' i
data 475,125    ' t
data 525,125    ' e
data 574,125    ' 2

