' Brownian motion demo using sprites.
' Peter Mather 2020

option explicit
option default none

#Include "../../common/welcome.inc"

we.check_firmware_version()

option console serial

mode 7
page write 1
dim integer x(64),y(64),c(64)
dim float direction(64)
dim integer i,j,k, collision=0
dim string q$
for i=1 to 64
 direction(i)=rnd*360 'establish the starting direction for each atom
 c(i)=rgb(rnd*255,rnd*255,rnd*255) 'give each atom a colour
 circle 10,10,4,1,,rgb(white),c(i) 'draw the atom
 sprite read i,6,6,9,9 'read it in as a sprite
next i
cls

Text 5, 5, "Press Q to Quit"

box 0,0,mm.hres,mm.vres
k=1
for i=mm.hres\9 to mm.hres\9*8 step mm.hres\9
 for j=mm.vres\9 to mm.vres\9*8 step mm.vres\9
   sprite show k,i,j,1
   x(k)=i
   y(k)=j
   vector k, direction(k), 0, x(k), y(k) 'load up the vector move
   k=k+1
 next j
next i

we.clear_keyboard_buffer()

do
 for i=1 to 64
   vector i, direction(i), 1, x(i), y(i)
   sprite show i,x(i),y(i),1
   if sprite(S,i)<>-1 then
     break_collision i
   endif
 next i
 page copy 1 to 0
 If we.is_quit_pressed%() Then Exit Do
loop

we.end_program()

Sub vector(obj As integer, angle As float, distance As float, x_new As integer, y_new As integer)
 Static float y_move(64), x_move(64)
 Static float x_last(69), y_last(64)
 Static float last_angle(64)
 If distance=0 Then
   x_last(obj)=x_new
   y_last(obj)=y_new
 EndIf
 If angle<>last_angle(obj) Then
   y_move(obj)=-Cos(Rad(angle))
   x_move(obj)=Sin(Rad(angle))
   last_angle(obj)=angle
 EndIf
 x_last(obj) = x_last(obj) + distance * x_move(obj)
 y_last(obj) = y_last(obj) + distance * y_move(obj)
 x_new=Cint(x_last(obj))
 y_new=Cint(y_last(obj))
Return

' keep doing stuff until we break the collisions
sub break_collision(atom as integer)
 Local integer j=1
 local float current_angle=direction(atom)
 'start by a simple bounce to break the collision
 If sprite(e,atom)=1 Then
   'collision with left of screen
   current_angle=360-current_angle
 Else If sprite(e,atom)=2 Then
   'collision with top of screen
     current_angle=((540-current_angle) Mod 360)
 Else If sprite(e,atom)=4 Then
   'collision with right of screen
   current_angle=360-current_angle
 Else If sprite(e,atom)=8 Then
   'collision with bottom of screen
   current_angle=((540-current_angle) Mod 360)
 Else
   'collision with another sprite or with a corner
   current_angle = current_angle+180
 endif
 direction(atom)=current_angle
 vector atom,direction(atom),j,x(atom),y(atom) 'break the collision
 sprite show atom,x(atom),y(atom),1
 'if the simple bounce didn't work try a random bounce
 do while (sprite(t,atom) or sprite(e,atom)) and j<10
   do
     direction(atom)= rnd*360
     vector atom,direction(atom),j,x(atom),y(atom) 'break the collision
     j=j+1
   loop until x(atom)>=0 and x(atom)<=MM.HRES-sprite(w,atom) and y(atom)>=0 and y(atom)<=MM.VRES-sprite(h,atom)
   sprite show atom,x(atom),y(atom),1
 loop
 ' if that didn't work then place the atom randomly
 do while (sprite(t,atom) or sprite(e,atom))
   direction(atom)= rnd*360
   x(atom)=rnd*(mm.hres-sprite(w,atom))
   y(atom)=rnd*(mm.vres-sprite(h,atom))
   vector atom,direction(atom),0,x(atom),y(atom) 'break the collision
   sprite show atom,x(atom),y(atom),1
 loop
End Sub
