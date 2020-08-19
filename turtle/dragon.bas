' Dragon curve
' Author: ???

#Include "../common/common.inc"

Mode 1,8
Cls
we.clear_keyboard_buffer()

text 100,500,"Dragon Curve - a Fractal","CT"

do
  do
    print @(0,520) "Order: (1-19)"
    input "0 to quit: "; dord
  loop until dord >= 0 and dord < 20

  If dord = 0 Then we.quit% = 1 : Exit Do

  we.clear_keyboard_buffer()

  quit = 0
  dord = dord - 1
  dist = MM.HRES/2/(sqr(2)^dord)

  cls
  turtle reset
  text 80, 0,"Dragon Curve","CT",2
  text 80,20,"Order:" + str$(dord+1), "CT",2
  turtle pen up   ' no line yet
  turtle move MM.HRES * .25, MM.VRES * .55
  turtle pen down

  turtle heading 90 - (dord MOD 8) * 45
  turtle pen colour rgb(red)
  DrawDragon(dord,1)

  turtle heading 270 - (dord MOD 8) * 45
  turtle pen colour rgb(green)
  DrawDragon(dord,1)

loop

we.end_program()

sub DrawDragon(ord, sig)
  If we.check_for_quit%() Then Exit Sub

  if ord = 0 then
    turtle forward dist
  else
    DrawDragon(ord-1,  1)
    turtle turn right 90 * sig
    DrawDragon(ord-1, -1)
  endif
end sub
