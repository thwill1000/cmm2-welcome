' Author: "vegipete"
' Short demo code to display playing cards.
' Card graphics suit mode 1, 800x600
'
' Base images taken from Wikipedia and massaged slightly
' to suit the CMM2 colours and transparency and resolution.

#Include "../../common/welcome.inc"

dim k$
dim source(52,2)  ' hold x,y coords of each card source image
dim shuffle(52)   ' shuffled cards
for i = 1 to 52 : shuffle(i) = i : next i

' Load card graphics onto page 1
' Images are stored 10 across and 6 vertically
' Each card cell is 80 wide by 100 tall, the actual
' card graphics are 74 wide by 94 tall
page write 1
cls
load png WE.PROG_DIR$ + "/playing_cards_deck.png",0,0

' fill source(x,y) with coordinates for each card on page 1 buffer
for i = 0 to 9
  source(i+1,1) = 3 + 80 * i    ' spades 1 to 10
  source(i+1,2) = 3             ' same y coordinate for all

  source(i+14,1) = 3 + 80 * i   ' hearts 1 to 10
  source(i+14,2) = 103

  source(i+27,1) = 3 + 80 * i   ' diamonds 1 to 10
  source(i+27,2) = 203

  source(i+40,1) = 3 + 80 * i   ' clubs 1 to 10
  source(i+40,2) = 303
next i

for i = 0 to 2
  source(i+11,1) = 3 + 80 * i   ' spades J Q K
  source(i+11,2) = 403

  source(i+24,1) = 3 + 80 * i   ' hearts J Q K
  source(i+24,2) = 503

  source(i+37,1) = 243 + 80 * i ' diamonds J Q K
  source(i+37,2) = 403

  source(i+50,1) = 243 + 80 * i ' clubs J Q K
  source(i+50,2) = 503
next i

' dimensions of visible card
cwidth = 74 : cheight = 94

' sprite-ify 52 cards. Should do backs also.
' still on page 1 so that srite read can find the images
for i = 1 to 52
  sprite read i,source(i,1),source(i,2),cwidth,cheight
next i

' Switch to page 0 so we can show some images
page write 0
cls &h00A000  ' green felt card table surface

' show a shuffled deck around the screen
ShuffleDeck
for i = 1 to 52
  x = MM.HRES/2 -  cwidth/2 + 300 * cos((i+15)*0.114)
  y = MM.VRES/2 - cheight/2 + 250 * sin((i+15)*0.114)
  blit source(shuffle(i),1),source(shuffle(i),2),x,y,cwidth,cheight,1,4
next i

' show 2 face down cards
blit 8*80+3,4*100+3,250,250,cwidth,cheight,1,4
blit 9*80+3,4*100+3,470,250,cwidth,cheight,1,4

' show each card one by one, left/right arrow to change
text 400,350,"Change card with left/right arrows.","CT",1,1,0,-1
text 400,370,"Press 'Q' to Quit.","CT",1,1,0,-1
text 400,420,"Type 'page copy 1,0' at command prompt","CT",1,1,0,-1
text 400,435,"to see image file.","CT",1,1,0,-1

do while inkey$ <> "" : loop ' clear keyboard buffer

card = 1
nc = 1
do
  if nc then  ' only draw a sprite if something has changed.
    sprite show card, 360,250,0
    nc = 0
  endif
  k$ = inkey$ ' look for arrow keys to change displayed card
  if asc(k$) = 130 then
    card = card - 1
    nc = 1
    if card < 1 then card = 52
  elseif asc(k$) = 131 then
    card = card + 1
    nc = 1
    if card > 52 then card = 1
  elseif lcase$(k$) = "q" then
    exit do
  endif
loop

we.end_program()

' splat the deck randomly on screen
'do
'  for i = 1 to 52
'    sprite show i,360,250,0 'rnd*700,rnd*480,0
'    pause 500
'  next i
'loop

' Shuffle the deck by swapping each position with a random position.
sub ShuffleDeck
  for i = 1 to 52
    c1 = int(rnd * 52) + 1
    tmp = shuffle(i)
    shuffle(i) = shuffle(c1)
    shuffle(c1) = tmp
  next i
end sub
