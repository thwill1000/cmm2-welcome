  ' LunarLander2v74.BAS
  ' Lunar Lander For Nostalganauts
  ' Written for the Colour Maximite 2 by Vegipete, August 2020
  '
  ' v75 - thwill:
  '     - updated to run on firmware 5.06.00 and tidied up Help overlay code
  ' v74 - Vegipete:
  '     - further fixes for image rotation with newest firmware; now
  '       uses a fixed sprite-sheet instead of generating the rotated
  '       images "on the fly".
  ' v73 - Vegipete:
  '     - added workaround for difference in direction of IMAGE ROTATE
  '       between firmware 5.05.05 and 5.05.06.
  ' v72 - Vegipete:
  '     - added introduction screen
  ' v7  - Vegipete:
  '     - sound tweaks, stuttering engine repaired, crumple landing added
  '     - gauges moved to subroutine and altered
  '     - exploding shrapnel when crashed
  ' v6  - Andrew_G:
  '     - fixed over-writing of "Press [H|h] for Help" text
  '     - tidied up with MMBASIC keywords in uppercase
  ' v5  - Andrew_G:
  '     - added help (of sorts)
  '     - added sun to moonscape
  '     - added up arrow as a panic stop/start/pause
  '     - added guages
  '     - made Landed.MOD louder
  ' v4  - Andrew_G:
  '     - added adjustment of sound volume and green landing pad
  '     - changed the 'Success' sound file to Landed.MOD
  ' v3  - BigMik
  '     - added sound
  ' v2  - Vegipete:
  '     - bug fix, allow high altitude, add pointer arrow, constants for parameters
  ' v1  - Vegipete:
  '     - initial version

  ' The program needs:
  '   Font #8 = CHR$ 128-131, ^ < \/ > Arrows (Defined below)
  '   Font #10 = CHR$ 32-43, Blank + 10 chunks of shrapnel (Defined below)
  ' The following files should be on the SD card in the same folder:
  '   "LanderPict.png"  - the lander sprites
  '   "EagleLanded.wav" - 'The Eagle has landed' sample
  '   "Success.wav"     - not used in this version but you can try it!
  '   "Crash.wav"
  '   "Crumple.wav"
  '   "lunar.bas"       - this file

#Include "../../common/welcome.inc"

  MODE 1,8  ' default but still...
  CLS

  CONST Padwidth = 60
  CONST Gravity = 0.1
  CONST Power = 0.5
  CONST StartFuel = 100
  CONST True = 1
  CONST False = 0

  DIM INTEGER help_on = False ' set True to have Help overlay shown at startup
  DIM surface(800)
  DIM INTEGER Vol_Adj, Mute = False, Pause_It = False
  DIM INTEGER Vol_Start = 25, Vol_Level = Vol_Start
  DIM INTEGER H_Angle, V_Angle, i
  
  DIM bbit(10,4)   ' chunks of exploding emplacement  x,y,dx,dy

  '***********************************
  ' colour parameters for gauge drawing routines
  DIM colrhbar(10,1)  'See DrawBarGauge subroutine heading for details
  colrhbar(0,0) = 9   : colrhbar(0,1) = &hFF0000
  colrhbar(1,0) =  80 : colrhbar(1,1) = &hF06000
  colrhbar(2,0) =  60 : colrhbar(2,1) = &hF0A000
  colrhbar(3,0) =  40 : colrhbar(3,1) = &hF0F000
  colrhbar(4,0) =  20 : colrhbar(4,1) = &h00F000
  colrhbar(5,0) =   0 : colrhbar(5,1) = &h00F000
  colrhbar(6,0) = -20 : colrhbar(6,1) = &hF0F000
  colrhbar(7,0) = -40 : colrhbar(7,1) = &hF0A000
  colrhbar(8,0) = -60 : colrhbar(8,1) = &hF06000
  colrhbar(9,0) = -80 : colrhbar(9,1) = &hFF0000

  DIM colrfbar(2,1)
  colrfbar(0,0) = 2   : colrfbar(0,1) = rgb(green)
  colrfbar(1,0) =  50 : colrfbar(1,1) = rgb(yellow)
  colrfbar(2,0) =  20 : colrfbar(2,1) = rgb(red)

  DIM colrvbar(5,1)
  colrvbar(0,0) = 4   : colrvbar(0,1) = &hA000A0
  colrvbar(1,0) =  60 : colrvbar(1,1) = &h4080F0
  colrvbar(2,0) =   0 : colrvbar(2,1) = rgb(green)
  colrvbar(3,0) = -25 : colrvbar(3,1) = rgb(yellow)
  colrvbar(4,0) = -40 : colrvbar(4,1) = rgb(red)

  DIM colrcbar(5,1)
  colrcbar(0,0) = 4   : colrcbar(0,1) = rgb(red)
  colrcbar(1,0) =  12 : colrcbar(1,1) = rgb(yellow)
  colrcbar(2,0) =   8 : colrcbar(2,1) = rgb(green)
  colrcbar(3,0) =  -8 : colrcbar(3,1) = rgb(yellow)
  colrcbar(4,0) = -12 : colrcbar(4,1) = rgb(red)

  PLAY VOLUME Vol_Start, Vol_Start

  '***********************************
  ' Sprites are no longer generated on the fly due to differences between
  ' different firmware versions.
  ' The behaviour of IMAGE ROTATE changed starting with version 5.05.05
  ' The sense of roation changed for mathematical consistency, requiring
  ' a special test to determine firmware version. More significantly, the
  ' rotation algorithm changed too, resulting in rotated images that had
  ' become gray.
  '
  ' To solve these problems for once and all, I reflashed my CMM2 with
  ' firmware version 5.05.04, regenerated the rotated lander images and
  ' created a sprite sheet with all images pre-generated.
  '
  ' The following is description of how it used to work:
  ' Build the lander sprites.
  ' The sprite file only contains images of the lander straight up
  ' with and without rocket burn. For nice rotation, 18 more images
  ' are generated, every 5 degrees, from 5 to 90 degrees (counter clockwise.)
  ' The rest of the circle is done by mirroring the sprite sideways/
  ' vertically/both.
  ' The base image is loaded onto page 2.
  ' Then the 90` rotation is built across the page on a 40 pixel grid.
  ' Finally, the 38 total sprites are then yanked from the page.
  PAGE WRITE 2
  CLS
  LOAD PNG WE.PROG_DIR$ + "/LanderPict.png"

  ' populate the sprites
  FOR i = 1 TO 19
    SPRITE READ i,(i-1)*40,0,40,40
    SPRITE READ 20+i,(i-1)*40,40,40,40
  NEXT i

  'Parameters for drawing instruments and help (alter these to suit your tastes)
  H_Factor = 10
  V_Factor = 10
  A_Factor = 10
  X_Ctr = mm.hres-50
  Y_Ctr = mm.vres-40
  X_Vol = 620         'Volume/Sound controls
  Y_Vol = Y_Ctr + 5
  Y_H = 52
  X_Fuel = 540        'Fuel gauge X location
  Y_Fuel = Y_Ctr - 7
  H_Fuel = 52
  X_Hzt = 220         'Horizontal speedometer X location
  Y_Hzt = Y_Ctr - 15
  H_Hzt = 52
  X_Vert = 320        'Vertical speedometer
  Y_Vert = Y_Ctr - 7
  H_Vert = 52
  X_Atd = 450
  Y_Atd = Y_Ctr -3

  '***********************************
  DrawStars   ' stars drawn on page 3 to keep 'em safe

  DoIntro

  DO
    PAGE WRITE 1
    CLS

    xlander = 400 ' lander coordinates
    ylander = 100
    vxlander = 0  ' lander velocity
    vylander = 0  ' positive UP!
    alander = 1   ' lander active sprite - so we hide the right one
    rlander = 1   ' lander rotation, 1 to 72 = 0 to 355 degrees
    fuel = 0
    xpad = 0      ' left edge of landing pad - set by CreateMoon

    CreateMoon
    DrawMoon    ' copies stars to work page, then draws moon

    TEXT MM.HRES/2,10,"Lunar Lander for Nostalganauts","CT",3,1,rgb(brown)

    SPRITE SHOW alander,xlander,ylander,1
    PAGE COPY 1,0,B

    Done = 0
    Engine = 0

    DO
      ' test for key-presses
      Direction = 0
      Burn = 0
      Vol_Adj = 0
      IF TIMER > 100 THEN  'to slow down key presses
        TIMER = 0
        Engine = 0
        IF KEYDOWN(0) THEN
          FOR i = 1 TO KEYDOWN(0)
            IF KEYDOWN(i) = 128 THEN                      ' up arrow, pause
              IF Pause_It THEN
                Pause_It = False
              ELSE
                Pause_It = True     'Pause and allow changes whilst paused
                vxlander = 0
                vylander = 0
              END IF
            END IF
            IF KEYDOWN(i) = 72 OR KEYDOWN (i) = 104 THEN ' H or h pressed, toggle HELP
              help_on = Not help_on
              ShowHelp()
            END IF
            IF KEYDOWN(i) = 130 THEN direction =  1    ' left arrow, rotate left
            IF KEYDOWN(i) = 131 THEN direction = -1    ' right arrow, rotate right
            IF KEYDOWN(i) = 43  THEN Vol_Adj =  5      ' +, increase volume
            IF KEYDOWN(i) = 45  THEN Vol_Adj = -5      ' -, decrease volume
            IF KEYDOWN(i) = 129 THEN Mute = (Mute = 0) ' down arrow, toggle MUTE
            IF KEYDOWN(i) = 32 AND fuel > 0 THEN       ' space, engine on
              Burn = 1
              Engine = 1
              PLAY STOP : PLAY TONE 100,250,50
            END IF
          NEXT i
        END IF
      END IF

      ' adjust and show sound volume
      Vol_Level = Vol_Level + Vol_Adj
      IF Vol_Level > 100 THEN Vol_Level = 100
      IF Vol_Level < 0 THEN Vol_Level = 0
      BOX X_Vol+1, Y_Vol-51, 8, 50,,RGB(BLACK), RGB(BLACK)  'Blank our Sound bar
      TEXT X_Vol+5, Y_Vol+13, "    ", CB, 7,1,RGB(GRAY),RGB(GRAY)
      TEXT X_Vol+5, Y_Vol+13, STR$(Vol_Level)+"%", CB, 7,1,RGB(WHITE),RGB(GRAY)
      IF Mute THEN
        PLAY VOLUME 0, 0
        BOX X_Vol+1, Y_Vol-1-Vol_Level\2, 8, Vol_Level\2,,RGB(Blue), RGB(Blue)
        TEXT X_Vol+6, Y_Vol+38, "MUTED", CB, 7,1,RGB(RED),RGB(GRAY)
      ELSE
        PLAY VOLUME Vol_Level, Vol_Level
        TEXT X_Vol+6, Y_Vol+38, "     ", CB, 7,1,RGB(RED),RGB(GRAY)
        BOX X_Vol+1, Y_Vol-1-Vol_Level\2, 8, Vol_Level\2,,RGB(green), RGB(Green)
      END IF

      ' adjust rotation
      rlander = rlander + direction
      IF rlander > 72 THEN rlander = rlander - 72
      IF rlander <  1 THEN rlander = rlander + 72

      IF Pause_It THEN
        ShowLander(rlander,Engine)
        PAGE COPY 1,0,B
        GOTO Paused
      END IF

      ' thrust
      IF Burn > 0 AND fuel > 0 THEN
        fuel = fuel - 1
        angle = (rlander - 1) * PI / 36
        vxlander = vxlander - Power * sin(angle)
        vylander = vylander + Power * cos(angle)
      END IF

      ' Gravity
      vylander = vylander - Gravity

      ShowGauges

      xlander = xlander + vxlander
      IF xlander < -30 THEN xlander = xlander + MM.HRES + 20
      IF xlander > MM.HRES-10 THEN xlander = xlander - MM.HRES - 20
      ylander = ylander - vylander

      ShowLander(rlander,Engine)
      PAGE COPY 1,0,B

      ' test for landing
      IF xlander > -20 AND xlander < 780 THEN   ' no test when off screen - neat bug!
        IF ylander > surface(xlander+20) - 32 THEN  ' touched the surface?
          ShowLander(rlander,0)                     ' engines off
          IF xlander > xpad - 5 AND xlander < xpad + Padwidth - 35 THEN ' over landing pad?
            IF rlander < 4 OR rlander > 70 THEN     ' near vertical?
              IF vylander > -2 THEN                 ' low vertical velocity?
                TEXT xlander+20,ylander-15,"Success!","CT",4,1,rgb(green)
                PlaySound$ = "EagleLanded.wav"
              ELSE
                TEXT xlander+20,ylander-40),"Crash!","CT",4,1,rgb(red)
                ctxt$ = "Too fast."
                TEXT xlander+20,ylander-15),ctxt$,"CT",4,1, RGB(WHITE)
                PlaySound$ = "crash.wav"
              END IF
            ELSEIF rlander < 6 OR rlander > 68 THEN     ' close to vertical?
              TEXT xlander+20,ylander-65),"Crumple!","CT",4,1,rgb(red)
              TEXT xlander+20,ylander-40),"Not quite level enough.","CT",4,1, RGB(WHITE)
              TEXT xlander+20,ylander-15),"Maybe rescue will arrive in time.","CT",1,1, RGB(WHITE)
              PlaySound$ = "crumple.wav"
            ELSE
              TEXT xlander+20,ylander-40),"Crash!","CT",4,1,rgb(red)
              ctxt$ = "Too far off level."
              TEXT xlander+20,ylander-15),ctxt$,"CT",4,1, RGB(WHITE)
              PlaySound$ = "crash.wav"
            END IF
          ELSE
            TEXT xlander+20,ylander-40),"Crash!","CT",4,1,rgb(red)
            ctxt$ = "Missed the pad."
            TEXT xlander+20,ylander-15),ctxt$,"CT", 4,1, RGB(WHITE)
            PlaySound$ = "crash.wav"
          END IF
          PAGE COPY 1,0,D
          IF NOT Mute THEN PLAY STOP : PLAY WAV WE.PROG_DIR + "/" + PlaySound$
          IF PlaySound$ = "crash.wav" THEN Kaboom
          done = 1
        END IF
      END IF

Paused:
      PAUSE 50  'This controls the speed of the game

  LOOP UNTIL done

    PAGE WRITE 0
    TEXT MM.HRES/2,150,"Press [Enter] to try again.","CT",4,1, RGB(WHITE)
    TEXT MM.HRES/2,180,"Press [Q] to Quit.","CT", 4,1, RGB(WHITE)

    DO
      Tmp$ = INKEY$
      IF Tmp$ <> "" THEN
        IF UCASE$(Tmp$) = "H" THEN
          help_on = NOT help_on
          ShowHelp()
        END IF
        IF we.is_quit_key%(Tmp$) Then we.end_program()
        IF ASC(Tmp$) = 13 THEN EXIT DO  ' Return key, go again
      END IF
    LOOP
    PLAY STOP
    SPRITE HIDE alander
  LOOP

'***********************************
SUB Showlander(n,b)
  LOCAL x,y
  LOCAL offset = 0

  IF b THEN offset = 20  ' engine on sprite is 20 positions after engine off
  x = xlander+20         ' local copy to deal with sky high lander
  y = ylander

  BOX 0,0,MM.HRES,12,1,0,0    ' erase anything left on pointer row

  arrow$ = " "      ' start with no arrow
  IF y < -39 THEN
    y = -39
    arrow$ = chr$(146)  ' use arrow if lander is too high to see
  END IF

  IF x < -5 THEN x = -5
  IF x > MM.HRES+4 THEN x = MM.HRES+4
  TEXT x,1, arrow$, "CT"  ' draw blank or arrow

  SPRITE HIDE alander
  SELECT CASE n
    CASE 1 TO 19
      alander = n + offset
      sprite show alander,xlander,y,1,0
    CASE 20 TO 36
      alander = 38-n + offset
      sprite show alander,xlander,y+2,1,2
    CASE 37 TO 55
      alander = n-36 + offset
      sprite show alander,xlander,y+2,1,3
    CASE 56 TO 72
      alander = 74-n + offset
      sprite show alander,xlander,y,1,1
  END SELECT
END SUB   'ShowLander

'***********************************
SUB ShowGauges
  local gval

  DrawBarGauge(X_Fuel+1,Y_Fuel,20,85,Fuel,100,"Fuel"," ",colrfbar())
  gval = int(vxlander * H_Factor)
  DrawBarGauge(X_Hzt,Y_Hzt,100,20,gval,100,"HORIZONTAL VELOCITY"," ",colrhbar())
  gval = int(vylander * V_Factor)
  DrawBarGauge(X_Vert,Y_Vert,20,85,gval,50,"VERTICAL","VELOCITY",colrvbar())
  gval = (1 - rlander) * 5
  if gval < -180 then gval = 360 + gval
  DrawCircleGauge(X_Atd,Y_Atd-4,42,12,0,179.5,gval,180,"ATTITUDE",colrcbar())

END SUB

'***********************************
SUB ShowHelp()

  Const FORE = RGB(White)
  Const BACK = RGB(Gray)

  ' Note:
  '   X_Ctr = MM.HRES-50
  '   Y_Ctr = MM.VRES-40

  ' Overwrite help overlay area with background coloured box.
  Box X_Vol+25, Y_Ctr-65, MM.HRES-X_Vol-25, MM.VRES-Y_Ctr+65, , BACK, BACK

  If Not help_on Then
    Text MM.HRES-10, Y_Ctr+28, "Press [H|h] for HELP.", "RB", 7, 1, RGB(Yellow), BACK
    Exit Sub
  EndIf

  ' Up arrow
  TEXT X_Ctr,     Y_Ctr-12, Chr$(128), CB, 8,1, FORE, BACK
  TEXT X_Ctr,     Y_Ctr-55, "PAUSE",   CB, 7,1, FORE, BACK
  TEXT X_Ctr,     Y_Ctr-45, "ON/OFF",  CB, 7,1, FORE, BACK

  ' Down arrow
  TEXT X_Ctr,     Y_Ctr+22, Chr$(129), CB, 8,1, FORE, BACK
  TEXT X_Ctr,     Y_Ctr+28, "MUTE",    CB, 7,1, FORE, BACK
  TEXT X_Ctr,     Y_Ctr+38, "ON/OFF",  CB, 7,1, FORE, BACK

  ' Left arrow
  TEXT X_Ctr-5,   Y_Ctr+5,  Chr$(130), RB, 8,1, FORE, BACK
  TEXT X_Ctr-45,  Y_Ctr+4,  "Rotate",  LB, 7,1, FORE, BACK
  TEXT X_Ctr-45,  Y_Ctr+14, "Left",    LB, 7,1, FORE, BACK

  ' Right arrow
  TEXT X_Ctr+5,   Y_Ctr+5,  Chr$(131), LB, 8,1, FORE, BACK
  TEXT X_Ctr+15,  Y_Ctr+4,  "Rotate",  LB, 7,1, FORE, BACK
  TEXT X_Ctr+15,  Y_Ctr+14, "Right",   LB, 7,1, FORE, BACK

  ' Spacebar
  BOX  X_Ctr-100, Y_Ctr-25, 50, 20, , FORE, BACK
  TEXT X_Ctr-75,  Y_Ctr-15, "Thrust",  CM, 7,1, FORE, BACK

  ' Sound level adjustment
  TEXT X_Vol+28,  Y_Vol+23, "+ Up",    LB, 7, 1, FORE, BACK
  TEXT X_Vol+28,  Y_Vol+33, "- Down",  LB, 7, 1, FORE, BACK
  BOX  X_Vol+25,  Y_Vol+13, 11, 10, , FORE
  BOX  X_Vol+25,  Y_Vol+24, 11, 10, , FORE

END SUB ' ShowHelp

'***********************************
SUB DrawMoon
  LOCAL INTEGER i
  PAGE COPY 3,1   ' copy stars to work page
  FOR i = 0 TO MM.HRES-1
    IF i > xpad AND i < xpad + Padwidth THEN
      LINE i,surface(i),i,MM.VRES-1,1,rgb(GRAY)
      PIXEL i,surface(i),rgb(green)  'landing pad
      'LINE i,surface(i),i,surface(i),1,rgb(green) 'landing pad
    ELSE
      LINE i,surface(i),i,MM.VRES-1,1,rgb(GRAY)
      IF surface(i+1) > surface(i) THEN   'This adds sunlight to the lunar surface
        LINE i, surface(i), i+1, surface(i+1),,RGB(Yellow)
      ELSE
        LINE i, surface(i), i+1, surface(i+1),,RGB(GRAY)
      END IF
    END IF
  NEXT i

  ShowHelp()

  ' Control Panel Frame
  rbox 150,502,450,120,10,&hC0C0C0,&hC0C0C0
  rbox 150,503,449,120,10,&h808080,&h808080
  rbox 154,507,441,120,8, &h101010,&h404040

  TEXT X_Vol+6, Y_Vol+28, "SOUND", "CB", 7,1,RGB(WHITE),RGB(GRAY)

END SUB 'DrawMoon

'***********************************
SUB CreateMoon
  LOCAL height
  LOCAL INTEGER i

  fuel = StartFuel

  xpad = INT(RND * 400) + 200 - Padwidth/2
  height = 475 - INT(RND * 100)  ' landing pad altitude

  FOR i = 0 TO Padwidth
    surface(xpad + i) = height
  NEXT i

  FOR i = xpad-1 TO 0 step -1
    surface(i) = surface(i+1) + 4.8 - 10*rnd  ' slight bias up
    IF surface(i) > MM.VRES-100 THEN surface(i) = MM.VRES-100
  NEXT i

  FOR i = xpad + Padwidth TO MM.HRES
    surface(i) = surface(i-1) + 4.8 - 10*rnd  ' slight bias up
    IF surface(i) > MM.VRES-100 THEN surface(i) = MM.VRES-100
  NEXT i
end sub 'CreateMoon

'***********************************
SUB DrawStars
  LOCAL INTEGER i
  PAGE WRITE 3
  CLS
  FOR i = 1 TO 200
    PIXEL 800*RND,500*RND,MAP(RND*255)
  NEXT i
  PAGE WRITE 1
END SUB 'DrawStars

'******************************************************
' Draw a centered bar gauge
' x,y : center of gauge
' h,v : horizontal & vertical size, larger one determines orientation
' rd  : reading, negative is left or down, +/- lim is full scale
' lim : reading for full scale
' t1$ : caption text line 1
' t2$ : caption text line 2
' coltab() : array of thresholds and colours
'
' coltab() format:                           these are standard 24 bit CMM2 colours
' coltab(0,0) = number of boundaries : coltab(0,1) = colour above top boundary
' coltab(1,0) = top boundary         : coltab(1,1) = colour below this boundary to next lower one
' ...
' coltab(n,0) = lowest boundary      ; coltab(n,1) = colour below this boundary
'
' Boundaries are given in terms of percentage.
sub DrawBarGauge(x,y,h,v,n,lim,t1$,t2$,coltab())
  local integer xt,yt,hor,size,gcol,i
  local float rd, pcnt
  rd = n
  hor = (h > v)
  xt = x - h/2
  yt = y - v/2
  box xt - 1, yt - 1, h+2, v+2, 1, rgb(white), 0
  if rd < -ABS(lim) then rd = -ABS(lim)
  if rd >  ABS(lim) then rd =  ABS(lim)

  pcnt = n*100/lim
'? @(400,50) pcnt "   ";
  gcol = coltab(0,1)  ' start with MAX colour
  for i = 1 to coltab(0,0)
'? @(400,70) coltab(i,0) "     ";
    if pcnt >= coltab(i,0) then exit for
    gcol = coltab(i,1)
  next i

  if hor then
    size = int(abs(rd) * h / 2 / lim)
    if rd < 0 then
      box x-size,yt,size,v,1,gcol,gcol
    else
      box x     ,yt,size,v,1,gcol,gcol
    endif
    text x,y+v/2+4 ," "+STR$(n)+" ","CT",1,1,RGB(WHITE),RGB(GRAY)
    text x,y+v/2+18,t1$,"CT",7,1,RGB(WHITE),RGB(GRAY)
    text x,y+v/2+28,t2$,"CT",7,1,RGB(WHITE),RGB(GRAY)
  else
    size = int(abs(rd) * v / 2 / lim)
    if rd > 0 then
      box xt,y-size,h,size,1,gcol,gcol
    else
      box xt,y     ,h,size,1,gcol,gcol
    endif
    text x+h/2+4,y-10," "+STR$(n)+" ","LB",1,1,RGB(WHITE),RGB(GRAY)
    text x+h/2+4,y,t1$,"LM",7,1,RGB(WHITE),RGB(GRAY)
    text x+h/2+4,y+10,t2$,"LM",7,1,RGB(WHITE),RGB(GRAY)
  endif

  ' draw center line
  if hor then
    line x ,yt, x  ,yt+v,1,rgb(white)  'horizontal gauge
  else
    line xt,y ,xt+h, y  ,1,rgb(white)  'vertical gauge
  endif

end sub

'******************************************************
' Draw a centered circular gauge
' x,y : center of gauge
' r,t : outer radius and thickness
' ctra, maxa : center angle, max angle
' rd  : reading, negative is left or down, +/- lim is full scale
' lim : reading for full scale
' t1$ : caption text line 1
' coltab() : array of thresholds and colours
sub DrawCircleGauge(x,y,r,t,ctra,maxa,n,lim,t1$,coltab())
  local integer xt,yt,hor,dlta,gcol,i
  local float rd, pcnt
  rd = n

  arc x,y,r-t-1,r+1,ctra-maxa,ctra+maxa,rgb(white)  ' white outline
  arc x,y,r-t  ,r  ,ctra-maxa,ctra+maxa,0           ' black inner area

  if rd < -ABS(lim) then rd = -ABS(lim)
  if rd >  ABS(lim) then rd =  ABS(lim)

  pcnt = n*100/lim
  gcol = coltab(0,1)  ' start with MAX colour
  for i = 1 to coltab(0,0)
    if pcnt >= coltab(i,0) then exit for
    gcol = coltab(i,1)
  next i

  dlta = int(abs(rd) * maxa / lim)
  if dlta < 1 then dlta = 1

  text x,y-2," "+STR$(n)+" ","CB",1,1,RGB(WHITE),RGB(GRAY)
  text x,y,t1$,"CT",7,1,RGB(WHITE),RGB(GRAY)

  if n < 0 then
    arc x,y,r-t,r,ctra-dlta,ctra,gcol
  else
    arc x,y,r-t,r,ctra,ctra+dlta,gcol
  endif

  ' draw center line
  x1 = x+(r-t)*sin(rad(ctra)) : x2 = x+r*sin(rad(ctra))
  y1 = y-(r-t)*cos(rad(ctra)) : y2 = y-r*cos(rad(ctra))
  line x1,y1,x2,y2,1,rgb(white)

  x1 = x+(r-t)*sin(rad(ctra+maxa)) : x2 = x+r*sin(rad(ctra+maxa))
  y1 = y-(r-t)*cos(rad(ctra+maxa)) : y2 = y-r*cos(rad(ctra+maxa))
  line x1,y1,x2,y2,1,rgb(white)

  x1 = x+(r-t)*sin(rad(ctra-maxa)) : x2 = x+r*sin(rad(ctra-maxa))
  y1 = y-(r-t)*cos(rad(ctra-maxa)) : y2 = y-r*cos(rad(ctra-maxa))
  line x1,y1,x2,y2,1,rgb(white)

end sub

'***********************************
sub Kaboom  ' Sudden unexpected violent disassembly
  local i,j

  ' create 10 bits of shrapnel
  for i = 1 to 10
    bbit(i,0) = 1
    bbit(i,1) = xlander+20 : bbit(i,3) = rnd * 10 - 5 + vxlander/3
    bbit(i,2) = ylander+25 : bbit(i,4) = -2 - rnd * 5 + vylander/5
  next i

  page write 0
  for i = 2 to 100

   ' blank out old pieces
    for j = 1 to 10
      if bbit(j,0) then text bbit(j,1),bbit(j,2),chr$(32),"CM",10
    next j

'    c = &h1000000 * int((30 - i)/2) + &hFFFF00  ' create amount of transparency
'    circle xlander,ylander+5,i,1,1,c,c

    for j = 1 to 10
      if bbit(j,0) then
        bbit(j,1) = bbit(j,1) + bbit(j,3)
        bbit(j,2) = bbit(j,2) + bbit(j,4) : bbit(j,4) = bbit(j,4) + .2  ' gravity
        if pixel(bbit(j,1),bbit(j,2)) = pixel(MM.HRES-2,MM.VRES-20) THEN
          bbit(j,0) = 0   ' make shrapnel stop moving
        endif
        text bbit(j,1),bbit(j,2),chr$(32+j),"CM",10,,,-1
      endif
    next j

    TEXT xlander+20,ylander-40),"Crash!","CT",4,1,rgb(red)
    TEXT xlander+20,ylander-15),ctxt$,"CT",4,1, RGB(WHITE)

    pause 20

  next i
  page write 1

end sub

'***********************************
sub DoIntro
  local lx, ly
  local intro$
  local i

  lx = 400
  ly = 50

  PAGE WRITE 1
  CLS

  CreateMoon
  DrawMoon    ' copies stars to work page, then draws moon
  ShowGauges

  TEXT MM.HRES/2,10,"Lunar Lander for Nostalganauts","CT",3,1,rgb(brown)

  i = 40
  restore welcometext
  do
    read intro$
    if intro$ = "0" then exit do
    TEXT 10,i,intro$,"LT",4,1,&h80FF80,-1
    i = i + 20
  loop

  do
    SPRITE SHOW 1,lx,ly,1
    PAGE COPY 1,0,B
    lx = lx + 2
    IF lx > MM.HRES-10 THEN lx = lx - MM.HRES - 20
    pause 20
  loop until inkey$ <> ""

  sprite hide 1
end sub

welcometext:
  data  "Welcome!"
  data  "The first Lunar Excursion Module touched down on the moon on July 20,1969."
  data  "That fall, the first text-based Lunar Lander game was written by Jim Storer"
  data  "for a DEC PDP-8 computer. The first real-time graphical version of Lunar Lander"
  data  "was released in 1973. Now, more than 50 years later, you too can attempt to"
  data  "land on the moon. Land gently - your life depends on it!"
  data  " "
  data  "Use the left and right arrow keys to rotate the lander. Use the space bar to"
  data  "fire the engine. Use the up arrow to pause."
  data  "Use the down arrow to toggle the sound and + and - to adjust the volume"
  data  ""
  data  "To land successfully, your vertical velocity must be low enough, your"
  data  "attitude must be close to vertical and you must be completely on the pad."
  data  ""
  data  "Please do not make new craters on the lunar surface."
  data  ""
  data  "Press any key to start your landing mission..."
  data  "0"

'***********************************
  ' Andrew_G - Arrows 24x32.bas
  ' Font type    : Full (4 characters)
  ' Font start   : CHR$(128)
  ' Font size    : 24x32 pixels
  ' Memory usage : 388 bytes
  '
DefineFont #8
  04802018 00000000 3C000018 007E0000 0100FF00 990380DB E01807C0 1C70180E
  18183818 08181018 00001800 18000018 00180000 00001800 18000018 00180000
  00001800 18000018 00180000 00001800 00000000 00000000 00000000 00000000
  00000000 00000000 18000018 00180000 00001800 18000018 00180000 00001800
  18000018 00180000 00001800 18100018 18181808 0E38181C 18077018 C09903E0
  0080DB01 7E0000FF 003C0000 00001800 00000000 00000000 00000000 00000000
  00000000 00000000 00000000 00000000 0100E000 800300C0 00000700 1C00000E
  00380000 00007000 FFFFFFFF 0070FFFF 00003800 0E00001C 00070000 00800300
  0000C001 000000E0 00000000 00000000 00000000 00000000 00000000 00000000
  00000000 00000000 00000000 00000000 00000700 01008003 E00000C0 00700000
  00003800 0E00001C FFFFFFFF 0000FFFF 1C00000E 00380000 00007000 C00100E0
  00800300 00000007 00000000 00000000 00000000 00000000 00000000 00000000
  00000000 00000000
End DefineFont

' vegipete: 10 chunks of shrapnel, plus blank
' Font type    : 11 characters
' Font start   : CHR$(32)
' Font size    : 8x8 pixels
' Memory usage : 92 bytes
DefineFont #10
  0B200808
  00000000 00000000 3E380000 00000818 1C0C0000 0008083C 18100000 00001C7C
  3C101000 00003038 180C0000 00006078 18303000 0000041C 1E060000 00003018
  783C1000 00000C48 30220600 00081830 36120000 0000283C
End DefineFont
