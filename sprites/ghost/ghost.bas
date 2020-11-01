' Peter Mather's Ghost Demo.  How to use Sprites.
' source code from: https://www.thebackshed.com/forum/ViewTopic.php?TID=12105&PID=146263
' image files from: https://www.thebackshed.com/forum/uploads/matherp/2020-05-12_210926_Parts.zip

#Include "../../common/welcome.inc"

' Set to 320x200 mode with 2 video layers and 12-bit colour.
' Page 0 is the bottom layer and page 1 is the top.
mode 3,12

' Clear the first three framebuffers (pages)
for i=0 to 2 : page write i : cls : next i

' Load a sprite which is the image of the ghost from a png file.
' The fact it is a png is important as png files encode transparency as well as solid colours.
sprite loadpng 1, WE.PROG_DIR$ + "/ghost.png"

' Set that we are going to write to the background layer.
page write 0

' Load the background image to the background layer - page 0.
load png WE.PROG_DIR$ + "/background.png"
text 0, 0, "Press Q to Quit", "", 1

' Initialise the display position of the ghost.
x=100
y=50

' Initialise the transparency of the ghost.
' Transparencies go from 1 (nearly invisible) to 15 (solid colour).
t=8

' Set to write to page 2 which is not being displayed.
page write 2

' Output the ghost on page 2.
sprite show 1,x,y,1

' Clear the keyboard buffer.
do while inkey$ <> "" : Loop

' Main process loop.
i = 0
do

  ' Do some silly maths to create a random walk of the ghost in both position and
  ' transparency while keeping it within the display bounds and the transparency
  ' within useful limits.
  i=i+1
  if i mod 5 = 0 then c=rnd()-0.5
  if i mod 3 = 0 then a=rnd()*8-4
  if i mod 3 = 0 then b=rnd()*6-3
  x=x+a
  if x<0 then x=0
  if x>MM.HRES-sprite(w,1) then x=mm.hres-sprite(w,1)
  y=y+b
  if y<0 then y=0
  if y>MM.VRES-sprite(h,1) then y=mm.vres-sprite(h,1)
  t=t+c
  if t<3 then t=3
  if t>12 then t=12

  ' Display the sprite in the new position and with the new transparency.
  sprite transparency 1,t
  sprite show 1,x,y,1

  ' Now copy page 2 to the foreground layer during frame blanking.
  ' This ensures that there are no tearing effects in the image.
  page copy 2 to 1,b

  ' Exit when "Q" is pressed.
  if ucase$(inkey$) = "Q" then exit do

  ' Slow things down a bit, the CMM2 is too fast.
  pause 100

loop

we.end_program()
