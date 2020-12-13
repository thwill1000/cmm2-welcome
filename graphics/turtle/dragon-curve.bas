' Dragon curve
' Author: "vegipete"

#Include "../common/welcome.inc"

Mode 1,8
Cls

Dim k$

For i% = 1 To 19
  Turtle Reset
  s$ = "Dragon Curve, Order " + Str$(i%)
  Text 0, 0, s$, "", 2
  s$ = "Press Q for Quit"
  If i% < 19 Then s$ = s$ + ", or any other key for the next pattern"
  Text 2, 25, s$, "", 1

  we.clear_keyboard_buffer()
  k$ = ""

  dord = i% - 1
  dist = MM.HRES/2/(sqr(2)^dord)

  turtle pen up
  turtle move MM.HRES * .25, MM.VRES * .55
  turtle pen down

  turtle heading 90 - (dord MOD 8) * 45
  turtle pen colour rgb(red)
  DrawDragon(dord,1)

  turtle heading 270 - (dord MOD 8) * 45
  turtle pen colour rgb(green)
  DrawDragon(dord,1)

  If k$ = "" Then k$ = we.wait_for_key$()
  If we.is_quit_key%(k$) Then Exit For
Next i%

If Not we.is_quit_key%(k$) Then we.wait_for_quit()
we.end_program()

sub DrawDragon(ord, sig)
  If k$ = "" Then k$ = Inkey$
  If k$ <> "" Then Exit Sub

  if ord = 0 then
    turtle forward dist
  else
    DrawDragon(ord-1,  1)
    turtle turn right 90 * sig
    DrawDragon(ord-1, -1)
  endif
end sub
