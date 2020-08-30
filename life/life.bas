' John Conway's Game of Life for Colour Maximite 2
' Authors: Bill McKinley, TassyJim & Thomas Hugo Williams

Option Explicit On
Option Default Integer
Option Base 0

#Include "../common/welcome.inc"

' Things that can be changed:
Const MatX = 66   ' Matrix horizontal size
Const PT = 0    ' Pause time in mS between display updates
Const initialPause = 3000 ' time to display starting pattern
Const RandL! = 0.3 ' For random life. less than =< RandL means there is life
Dim states(4) = (0, RGB(Black), RGB(Yellow), RGB(Green), RGB(127, 0, 0))
' End of configurable values

Const DIAM = MM.HRES/matX
Const MatY = INT(MatX * MM.VRES / MM.HRES) ' Matrix height

Dim a, b, gen, wrap, alive
Dim rate!, rateX!
Dim k$
Dim enhanced = 1
Dim dead = 1, born = 2, mature = 3, dying = 4
Dim M(MatX+1, MatY+1,2) ' The  matrix of life
Dim Mx(MatX+1, MatY+1) ' copy of starting pattern

make_tiles()

DO
  page write 0
  k$ = show_intro$()
  If LCase$(k$) = "q" Then Exit Do
  page write 1
  CLS
  init_matrix()

  If enhanced Then
    ' With enhanced visualisation newly "born" cells, surviving "mature"
    ' cells and cells that have just died are all shown in different
    ' colours.
    dead = 1 : born = 2 : mature = 3 : dying = 4
  Else
    ' With traditional visualisation cells that have just died are not
    ' shown and there is no distinction between "born" and "mature" cells.
    dead = 1 : born = 3 : mature = 3 : dying = 1
  EndIf

  initial_gen()
  PAUSE initialPause
  TIMER = 0     ' reset for next timer
  DO            ' main Program loop
    next_gen()
    PAUSE PT
    rate! = Timer - rateX! - PT
    rateX! = Timer
  LOOP UNTIL INKEY$ <> "" ' loop forever or until a keypress
LOOP

we.quit% = 1
we.end_program()

Function show_intro$()
  Local k$
  Local x = 175
  Local on_off$(1) = ("OFF", "ON")

  Cls

  Do
    Text MM.HRES/2, 50, "CONWAY'S GAME OF LIFE", cm, 5, 1, RGB(yellow)
    Text x, 125, "S    Random board", "", 3, 1
    Text x, 150, "R    Replay previous board", "", 3, 1
    Text x, 175, "0-9  Preset board", "", 3, 1
    Text x, 200, "E    Edit the board", "", 3, 1
    Text x + 90, 225, "- Arrow keys to navigate", "", 1, 1
    Text x + 90, 240, "- [Space] to toggle", "", 1, 1
    Text x + 90, 255, "- [Enter] when done", "", 1, 1
    Text x, 270, "W    Wrap display     [" + on_off$(wrap) + "] ", "", 3, 1
    Text x, 295, "V    Enhanced visuals [" + on_off$(enhanced) + "] ", "", 3, 1
    If enhanced Then
      Blit 2 * DIAM, 0, x + 90, 320, DIAM, DIAM, 2
      Text x + 110, 320, "Neonate"
      Blit 3 * DIAM, 0, x + 185, 320, DIAM, DIAM, 2
      Text x + 205, 320, "Mature"
      Blit 4 * DIAM, 0, x + 270, 320, DIAM, DIAM, 2
      Text x + 290, 320, "Dying"
    Else
      Blit mature * DIAM, 0, x + 90, 320, DIAM, DIAM, 2
      Text x + 110, 320, "Life                          "
    EndIf
    Text x, 335, "Q    Quit", "", 3, 1

    Do : k$ = Inkey$ : Loop Until k$ <> ""
    Select Case LCase$(k$)
      Case "w" : wrap = Not wrap
      Case "v" : enhanced = Not enhanced
      Case "r", "s", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "e", "q"
        Exit Do
    End Select
  Loop

  show_intro$ = k$
End Function

' Initialises the matrix of life.
Sub init_matrix()
  a = 0
  b = 1
  rate! = 0.0
  rateX! = 0.0
  gen = 0

  Select Case LCase$(k$)
    Case "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" : read_matrix(k$)
    Case "r" : restore_matrix()
    Case "e" : edit_matrix()
    Case "s" : random_matrix()
    Case Else : Error "Unknown state: " + k$
  End Select

  backup_matrix()

End Sub

Sub read_matrix(seed$)
  Local x, y

  Select Case seed$
    Case "1" : Restore glider
    Case "2" : Restore blinker
    Case "3" : Restore toad
    Case "4" : Restore beacon
    Case "5" : Restore penta_decathlon
    Case "6" : Restore pulsar
    Case "7" : Restore lw_spaceship
    Case "8" : Restore hw_spaceship
    Case "9" : Restore hw_spaceship
    Case "0" : Restore diehard
    Case Else : Error "Unknown seed"
  End Select

  For y = 1 To MatY
    For x = 1 To MatX
      M(x, y, b) = 0
    Next x
  Next y

  Do
    Read x
    Read y
    If x = -1 Then Exit Do
    If y = -1 Then Print "Error in Data", x, y : Exit Do
    M(x, y, b) = 1
  Loop

  dying = y*3+1 ' 1 or 4 depending on data

End Sub

Sub restore_matrix()
  Local x, y
  For x = 1 To MatX
    For y = 1 To MatY
      M(x, y, b) = Mx(x, y)
    Next y
  Next x
  dying = Mx(0,0)
End Sub

Sub random_matrix()
  Local x, y
  For y = 2 To MatY - 1
    For x = 2 To MatX - 1
      If Rnd() <= RandL! Then
        M(x, y, b) = 1
      Else
        M(x, y, b) = 0
      ENDIF
    Next x
  Next y
  dying = 4
End Sub

Sub backup_matrix()
  Local x, y
  For x = 1 To MatX
    For y = 1 To MatY
      Mx(x, y) = M(x, y, b)
      Mx(0, 0) = dying
    Next y
  Next x
End Sub

' Shows the initial generation of life.
Sub initial_gen()
  Local x, y
  FOR y = 1 TO MatY
    FOR x = 1 TO MatX
      IF M(x, y, b) = 1 THEN
        draw_cell(x, y, born)
      ENDIF
    NEXT x
  NEXT y
  TEXT 10,1,"Initial Generation"
  page copy 1 to 0
End Sub

' Breeds and shows the next generation of life.
Sub next_gen()
  Local x, y, d, i
  b = a : a = 1 - a ' swap a and b
  gen = gen + 1
  alive = 0
  IF wrap = 1 THEN
    ' wrap the corners
    M(0,0, a) = M(MatX,MatY, a)
    M(MatX+1,MatY+1, a) = M(1,1, a)
    M(0,MatY+1, a) = M(MatX,1, a)
    M(MatX+1,0, a) = M(1,MatY, a)
    ' wrap the edges
    FOR i = 1 TO MatX
      M(i,0, a) = M(i,MatY, a)   ' top
      M(i,MatY+1, a) = M(i,1, a) ' bottom
    NEXT i
    FOR i = 1 TO MatY
      M(0,i, a) = M(MatX,i, a)   ' left
      M(matX+1,i, a) = M(1,i, a) ' right
    NEXT i
  ENDIF
  FOR y = 1 TO MatY
    FOR x = 1 TO MatX
      d = M(x-1,y-1,a) + M(x-1,y,a) + M(x-1,y+1,a)
      d = d + M(x,y-1,a) + M(x,y+1, a)
      d = d + M(x+1,y-1,a) + M(x+1,y,a) + M(x+1,y+1,a)
      d = d MOD 10
      IF M(x,y,a) = 1 THEN
        IF d = 2 OR d = 3 THEN
          draw_cell(x,y, mature)
          M(x,y,b) = 1
          alive = alive + 1
        ELSE
          draw_cell(x,y, dying)
          M(x,y, b) = 10 ' flag this cell to be cleared next generation
        ENDIF
      ELSE
        IF d = 3 THEN
          draw_cell(x,y, born)
          M(x,y,b) = 1
          alive = alive + 1
        ELSE
          IF M(x,y,a) = 10 THEN draw_cell(x,y, dead)
          M(x,y,b) = 0
        ENDIF
      ENDIF
    NEXT x
  NEXT y
  TEXT 10,1,"Gen: "+STR$(gen)+", "+str$(alive)+" cells in"+STR$(rate!,5,0)+"mS  "
  page copy 1 to 0
End Sub

Sub draw_cell(x, y, stage)
  blit stage * DIAM, 0, (x-1)*DIAM, (y-1)*DIAM, DIAM, DIAM, 2
End Sub

' Edits the initial matrix/generation of life.
Sub edit_matrix()
  Local k$, x, y
  page write 0
  cls
  text 10,10,"Start with previous set Y/N ? "
  DO
    k$ = INKEY$
  LOOP UNTIL k$ <> ""
  page write 1
  if k$ = "Y" or k$ = "y" then
    for x = 1 to MatX
      for y = 1 to MatY
        M(x,y,b) = Mx(x,y)
        IF M(x, y, b) = 1 THEN
          draw_cell(x, y, born)
        ENDIF
      next y
    next x
    dying = Mx(0,0)
  else
    FOR y = 1 TO MatY
      FOR x = 1 TO MatX
        M(x, y, b) = 0
      NEXT x
    NEXT y
    dying = 4
  endif
  x = MatX\2
  y = MatY\2
  highlight_cell(x, y)
  do : loop until inkey$ = ""
  do
    DO
      k$ = INKEY$
    LOOP UNTIL k$ <> ""
    select case k$
      case chr$(13) ' all done
        exit do
      case CHR$(130) ' left arrow
        x = x - 1
        if x < 1 then x = MatX
        highlight_cell(x, y)
      case CHR$(131) ' right arrow
        x = x + 1
        if x > MatX then x = 1
        highlight_cell(x, y)
      case CHR$(128) ' down arrow
        y = y - 1
        if y < 1 then y = MatY
        highlight_cell(x, y)
      case CHR$(129) ' up arrow
        y = y + 1
        if y > MatY then y = 1
        highlight_cell(x, y)
      case " " ' toggle cell
        IF M(x, y, b) = 0 THEN
          M(x, y, b) = 1
          draw_cell(x, y, born)
        else
          M(x, y, b) = 0
          draw_cell(x, y, dead)
        ENDIF
        highlight_cell(x, y)
      case else
        '
    end select
  loop
  do : loop until inkey$ = ""
End Sub

Sub highlight_cell(x, y)
  page copy 1 to 0
  page write 0
  line (x-1)* DIAM,(y-1)* DIAM,(x)* DIAM,(y-1)* DIAM,1,rgb(red)
  line (x-1)* DIAM,(y)* DIAM,(x)* DIAM,(y)* DIAM,1,rgb(red)
  line (x-1)* DIAM,(y-1)* DIAM,(x-1)* DIAM,(y)* DIAM,1,rgb(red)
  line (x)* DIAM,(y-1)* DIAM,(x)* DIAM,(y)* DIAM,1,rgb(red)
  page write 1
End Sub

' Prepare the images for blitting from page 2.
Sub make_tiles()
  Local a, b
  page write 2
  box 0,0,diam*5,diam*2,1,0,0
  for a = 1 to 4
    for b = 0 to 7
      CIRCLE (a+0.5)* DIAM, 0.5 * DIAM, DIAM/2 - b, 1,,bright(states(a),b*15), states(a)
    next b
  next a
End Sub

Function bright(c, p)
  ' given colour and percent, returns adjusted colour
  ' transparency is not altered
  if p > 100 then p = 100
  if p < 0 then p = 0
  bright = (c and &hFF000000)
  bright = bright +(((c and &hFF0000)*p/100) and &hFF0000)
  bright = bright +(((c and &hFF00)*p/100) and &hFF00)
  bright = bright +(((c and &hFF)*p/100) and &hFF)
end function

' Seeds are pairs of x,y cells ending in -1 then 0 or 1 for coloured dying cells
glider:
  DATA 4,7,5,7,6,7,6,6,5,5,-1,0
blinker:
  DATA 4,7,5,7,6,7,-1,0
toad:
  DATA 5,7,6,7,7,7,4,8,5,8,6,8,-1,0
beacon:
  DATA 4,7,5,7,4,8,7,9,6,10,7,10,-1,0
penta_decathlon:
  DATA 5, 7,6, 7,7, 7,5, 8,7, 8,5, 9,6, 9,7, 9
  DATA 5, 10,6, 10,7, 10,5, 11,6, 11,7, 11,5, 12
  DATA 6, 12,7, 12,5, 13,7, 13,5, 14,6, 14,7, 14,-1,1
pulsar:
  DATA 5,3,6,3,7,3,11,3,12,3,13,3,3,5,8,5,10,5,15,5
  DATA 3,6,8,6,10,6,15,6,3,7,8,7,10,7,15,7
  DATA 5,8,6,8,7,8,11,8,12,8,13,8,5,10,6,10,7,10,11,10,12,10,13,10
  DATA 3,11,8,11,10,11,15,11,3,12,8,12,10,12,15,12
  DATA 3,13,8,13,10,13,15,13,5,15,6,15,7,15,11,15,12,15,13,15
  DATA -1, 1
lw_spaceship:
  DATA 3,2,6,2,7,3,3,4,7,4,4,5,5,5,6,5,7,5,-1,1
mw_spaceship:
  DATA 5,2,3,3,7,3,8,4,3,5,8,5,4,6,5,6,6,6,7,6,8,6,-1,1
hw_spaceship:
  DATA 7,4,8,4,3,5,4,5,5,5,6,5,8,5,9,5,3,6,4,6,5,6,6,6,7,6,8,6
  DATA 4,7,5,7,6,7,7,7,-1,1
diehard:
  DATA 8,5,2,6,3,6,4,6,7,7,8,7,9,7,-1,1
