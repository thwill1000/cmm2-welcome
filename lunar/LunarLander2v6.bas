  ' Lunar Lander2v6.BAS
  ' Lunar Lander For Nostalganauts
  ' Written for the Colour Maximite 2 by Vegipete
  '   V4 Sound added by BigMik
  '   v4 to v6 by Andrew_G
  '   August 2020
  '
  ' v6 - fixed over-writing of "Press [H|h] for Help" text
  '	   - tidied up with MMBASIC keywords in uppercase 
  ' v5 - added help (of sorts)
  '    - added sun to moonscape
  '    - added up arrow as a panic stop/start/pause
  '    - added guages
  '    - made Landed.MOD louder
  ' v4 - added adjustment of sound volume and green landing pad
  '    - changed the 'Success' sound file to Landed.MOD
  '
  ' v3 - added sound - by BigMik
  ' v2 - Vegipete:
  '    - bug fix, allow high altitude, add pointer arrow, constants for parameters
  ' v1 - First try
  
  'The program needs:
  'Font #8 = CHR$ 128-131, ^ < \/ > (Defined below)
  'The following should be on the SD card:
  ' "LanderPict.png" - the lander graphic
  ' Landed.mod "The Eagle has landed"
  ' Success.wav - not used in this version but you can try it!
  ' Crash.wav
  
  'Option Explicit
  MODE 1,8  ' default but still...
  CLS
  
  CONST Padwidth = 60
  CONST Gravity = 0.1
  CONST Power = 0.5
  CONST StartFuel = 100
  CONST True = 1
  CONST False = 0
  
  DIM INTEGER Show_Help = False   'True   'Set this to have Help on or off on startup
  DIM surface(800)
  DIM INTEGER Vol_Adj, Mute = False, Pause_It = False
  DIM INTEGER Vol_Start = 5, Vol_Level = Vol_Start
  DIM INTEGER H_Angle, V_Angle, i
  
  PLAY VOLUME Vol_Start, Vol_Start
  
  '***********************************
  ' Build the lander sprites.
  ' The sprite file only contains images of the lander straight up
  ' with and without rocket burn. For nice rotation, 18 more images
  ' are generated, every 5 degrees, from 5 to 90 degrees (clockwise.)
  ' The rest of the circle is done by mirroring the sprite sideways/
  ' vertically/both.
  ' The base image is loaded onto page 2.
  ' Then the 90` rotation is built across the page on a 40 pixel grid.
  ' Finally, the 38 total sprites are then yanked from the page.
  PAGE WRITE 2
  CLS
  LOAD PNG "LanderPict.png"
  
  ' generate the rotations
  FOR i = 1 TO 18
    IMAGE ROTATE 0, 0,40,40,i*40, 0,i*5
    IMAGE ROTATE 0,40,40,40,i*40,40,i*5
  NEXT i
  
  ' populate the sprites
  FOR i = 1 TO 19
    SPRITE READ i,(i-1)*40,0,40,40
    SPRITE READ 20+i,(i-1)*40,40,40,40
  NEXT i
  
  'Parameters for drawing instruments and help (alter these to suit your tastes)
  H_Factor = 10
  V_Factor = 10
  X_Ctr = mm.hres-50
  Y_Ctr = mm.vres-40
  X_Vol = 550         'Volume/Sound controls
  Y_Vol = Y_Ctr
  Y_H = 52
  X_Fuel = 450        'Fuel gauge X location
  Y_Fuel = Y_Ctr
  H_Fuel = 52
  X_Hzt = 325         'Horizontal speedometer X location
  Y_Hzt = Y_Ctr
  X_Vert = 150        'Vertical speedometer
  Y_Vert = Y_Ctr -15
  
  '***********************************
  DO
    PAGE WRITE 1
    CLS
    
    TEXT MM.HRES/2,10,"Lunar Lander for Nostalganauts","CT",4,1,rgb(brown)
    
    xlander = 400 ' lander coordinates
    ylander = 100
    vxlander = 0  ' lander velocity
    vylander = 0  ' positive UP!
    alander = 1   ' lander active sprite - so we hide the right one
    rlander = 1   ' lander rotation, 1 to 72 = 0 to 355 degrees
    fuel = 0
    xpad = 0      ' left edge of landing pad - set by CreateMoon
    
    DrawStars
    CreateMoon
    DrawMoon
    SPRITE SHOW alander,xlander,ylander,1
    PAGE COPY 1,0,B
    Done = 0
    
    DO
      ' test for key-presses
      Direction = 0
      Burn = 0
      Vol_Adj = 0
      IF KEYDOWN(0) THEN
        IF TIMER > 100 THEN  'to slow down key presses
          TIMER = 0
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
            IF KEYDOWN (i) = 72 OR KEYDOWN (i) = 104 THEN ' H or h pressed, get HELP
              IF Show_Help THEN
                Show_Help = False
                Help
                TEXT MM.HRES-10,Y_CTR+28,"Press [H|h] for HELP.","RB",7,1, RGB(Yellow), RGB(GRAY)
              ELSE
                Show_Help = True
                Help
              END IF
            END IF
            IF KEYDOWN(i) = 130 THEN direction =  1       ' left arrow, rotate left
            IF KEYDOWN(i) = 131 THEN direction = -1       ' right arrow, rotate right
            IF KEYDOWN(i) = 43  THEN Vol_Adj = 1     '5   ' +, increase volume
            IF KEYDOWN(i) = 45  THEN Vol_Adj = -1    '-5  ' -, decrease volume
            IF KEYDOWN(i) = 129 THEN                      ' down arrow, toggle MUTE
              IF Mute THEN
                Mute = False
              ELSE
                Mute = True
              END IF
            END IF
            IF KEYDOWN(i) = 32 AND fuel > 0 THEN          ' space, engine on
              burn = 1
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
        ShowLander(rlander,burn)
        PAGE COPY 1,0,B
        GOTO Paused
      END IF
      
      ' thrust
      IF burn > 0 AND fuel > 0 THEN
        fuel = fuel - 1
        angle = (rlander - 1) * PI / 36
        vxlander = vxlander - Power * sin(angle)
        vylander = vylander + Power * cos(angle)
      END IF
      
      ' Gravity
      vylander = vylander - Gravity
      
      ' display velocity & fuel
      BOX X_Fuel+1, Y_Fuel-51, 8, 50,,RGB(BLACK), RGB(BLACK)  'Blank out fuel guage
      IF Fuel > 25 THEN
        BOX X_Fuel+1, Y_Fuel-1-Fuel\2, 8, Fuel\2,,RGB(Yellow), RGB(Yellow)
      ELSE
        BOX X_Fuel+1, Y_Fuel-1-Fuel\2, 8, Fuel\2,,RGB(RED), RGB(RED)
      END IF
      TEXT X_Fuel+5, Y_Fuel+13, "    ", CB, 7,1,RGB(GRAY),RGB(GRAY)
      TEXT X_Fuel+5, Y_Fuel+13, STR$(fuel), CB, 7,1,RGB(WHITE),RGB(GRAY)
      
      'H_Factor = 10
      TEXT X_Hzt+3, Y_Hzt+13, "      ", CB,7,1,RGB(GRAY),RGB(GRAY)
      TEXT X_Hzt+5, Y_Hzt+13, Str$(vxlander*H_Factor, -2, 1), CB, 7,1,RGB(WHITE),RGB(GRAY)
      
      ARC X_Hzt, Y_Hzt, 40, 50-1, 270, 90, RGB(BLACK)   'Blank out old gauge
      H_Angle = Cint(vxlander*H_Factor)
      IF H_Angle < -89 THEN
        ARC X_Hzt, Y_Hzt, 40,50-1 , 271, 360, RGB(red)
      ELSE IF H_Angle < 0 THEN
        ARC X_Hzt, Y_Hzt, 40,50-1 , 360+H_Angle, 360, RGB(red)
      END IF
      
      IF H_Angle > 89 THEN
        ARC X_Hzt, Y_Hzt, 40,50-1 , 0, 89, RGB(Green)
      ELSE IF H_Angle > 0 THEN
        ARC X_Hzt, Y_Hzt, 40,50-1 , 0, H_Angle, RGB(Green)
      END IF
      ' ignore special case when H_Angle = 0
      LINE X_Hzt,Y_Hzt-50,X_Hzt,Y_Hzt-40, ,RGB(WHITE) 'Centre bar
      
      'V_Factor = 10
      TEXT X_Vert, Y_Vert-10, "      ", CB,7,1,RGB(GRAY),RGB(GRAY)
      TEXT X_Vert, Y_Vert-10, Str$(vylander*V_Factor, -2, 1), CB, 7,1,RGB(WHITE),RGB(GRAY)
      
      ARC X_Vert, Y_Vert, 40,50-1,1, 179, RGB(BLACK)   'Blank out gauge
      V_Angle = cint(vylander*V_Factor)
      IF V_Angle <-89 THEN
        ARC X_Vert, Y_Vert, 40,50-1 , 91, 179, RGB(yellow)
      ELSE IF V_Angle <0 THEN
        ARC X_Vert, Y_Vert, 40,50-1 , 90, 90-V_Angle, RGB(yellow)
      END IF
      
      IF V_Angle > 89 THEN
        ARC X_Vert, Y_Vert, 40,50-1 , 1, 90, RGB(BROWN)
      ELSE IF V_Angle > 0 THEN
        ARC X_Vert, Y_Vert, 40,50-1 , 90-V_Angle, 90, RGB(BROWN)
      END IF
      ' ignore special case when V_Angle = 0
      LINE X_Vert+40, Y_Vert, X_Vert+50, Y_Vert,, RGB(WHITE)'Centre bar
      
      xlander = xlander + vxlander
      IF xlander < -30 THEN xlander = xlander + MM.HRES + 20
      IF xlander > MM.HRES-10 THEN xlander = xlander - MM.HRES - 20
      ylander = ylander - vylander
      
      ShowLander(rlander,burn)
      PAGE COPY 1,0,B
      
      ' test for landing
      IF xlander > -20 AND xlander < 780 THEN       ' no test when off screen
        IF ylander > surface(xlander+20) - 32 THEN  ' touched the surface?
          ShowLander(rlander,0)                     ' engines off
          IF xlander > xpad - 5 AND xlander < xpad + Padwidth - 35 THEN ' over landing pad?
            IF rlander < 3 OR rlander > 68 THEN     ' near vertical?
              IF vylander > -2 THEN                 ' low vertical velocity?
                TEXT xlander+20,ylander-15,"Success!","CT",4,1,rgb(green)
                'PLAY STOP : PLAY WAV "success.wav"
                PLAY STOP
                IF NOT Mute THEN
                  PLAY VOLUME 30, 30  ' Added because Landed.MOD is too quiet
                  PLAY MODFILE "Landed.Mod"
                  PAUSE 2000
                  PLAY STOP
                  PLAY VOLUME Vol_Level, Vol_Level
                END IF
              ELSE
                TEXT xlander+20,ylander-40),"Crash!","CT",4,1,rgb(red)
                TEXT xlander+20,ylander-15),"Too fast.","CT",4,1, RGB(WHITE)
                IF NOT Mute THEN PLAY STOP : PLAY WAV "crash.wav"
              END IF
            ELSE
              TEXT xlander+20,ylander-40),"Crash!","CT",4,1,rgb(red)
              TEXT xlander+20,ylander-15),"Too far off level.","CT",4,1, RGB(WHITE)
              IF NOT Mute THEN PLAY STOP : PLAY WAV "crash.wav"
            END IF
          ELSE
            TEXT xlander+20,ylander-40),"Crash!","CT",4,1,rgb(red)
            TEXT xlander+20,ylander-15),"Missed the pad.","CT", 4,1, RGB(WHITE)
            TEXT xlander+20,ylander-40),"Crash!","CT",4,1,rgb(red)
            TEXT xlander+20,ylander-15),"Missed the pad.","CT", 4,1, RGB(WHITE)
            IF NOT mute THEN PLAY STOP : PLAY WAV "crash.wav"
          END IF
          done = 1
          PAGE COPY 1,0
        END IF
      END IF
      
Paused:
      PAUSE 50  'This controls the speed of the game   
    
	LOOP UNTIL done
    
    PAGE WRITE 0
    TEXT MM.HRES/2,200,"Press [Enter] to go again.","CT",4,1, RGB(WHITE)
    TEXT MM.HRES/2,230,"Press [ESC] to go quit.","CT", 4,1, RGB(WHITE)
    
    DO
      Tmp$ = INKEY$
      IF Tmp$ <> "" THEN
        IF UCASE$(Tmp$) = "H" THEN ' H or h pressed, show or hide HELP
          IF Show_Help THEN
            Show_Help = False
            Help
            TEXT MM.HRES-10,Y_CTR+28,"Press [H|h] for HELP.","RB",7,1, RGB(Yellow), RGB(GRAY)
          ELSE
            Show_Help = True
            Help
          END IF
        END IF
        IF ASC(Tmp$) = 27 THEN END      ' Escape key, quit
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
  
  IF b THEN offset = 20
  x = xlander+20              ' local copy to deal with sky high lander
  y = ylander
  
  BOX 0,0,MM.HRES,12,1,0,0    ' erase anything left on pointer row
  arrow$ = " "
  IF y < -39 THEN
    y = -39
    arrow$ = chr$(146)
  END IF
  
  IF x < -5 THEN x = -5
  IF x > MM.HRES+4 THEN x = MM.HRES+4
  TEXT x,1, arrow$, "CT"
  
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
END SUB		'ShowLander
  
  '***********************************
SUB Help
  LOCAL INTEGER Col = RGB(WHITE)
  IF not Show_Help THEN
    Col = RGB(GRAY)
  ELSE    'Hide any Help text
    TEXT MM.HRES-10,Y_CTR+28,"                      ","RB",7,1, RGB(GRAY), RGB(GRAY)
  END IF
  
  'Show_Keys:   'The variables below are defined above but are retained here to assist
  '  X_Ctr = mm.hres-50
  '  Y_Ctr = mm.vres-40
  TEXT X_Ctr,Y_Ctr-12,chr$(128),CB,8,1,Col,RGB(GRAY)    'Up  arrow
  TEXT X_Ctr, Y_Ctr-55, "PAUSE",CB, 7,1, Col,RGB(GRAY)
  TEXT X_Ctr, Y_Ctr-45, "ON/OFF",CB, 7,1, Col,RGB(GRAY)
  
  TEXT X_Ctr,Y_Ctr+27-5,chr$(129),CB,8,1,Col,RGB(GRAY)  'Down  "
  TEXT X_Ctr, Y_Ctr+28, "MUTE",CB, 7,1, Col,RGB(GRAY)
  TEXT X_Ctr, Y_Ctr+38, "ON/OFF",CB, 7,1, Col,RGB(GRAY)
  
  TEXT X_Ctr-5,Y_Ctr+5,chr$(130),RB,8,1,Col,RGB(GRAY)   'Left  "
  TEXT X_Ctr-45, Y_Ctr+4, "Rotate",LB, 7,1, Col,RGB(GRAY)
  TEXT X_Ctr-45, Y_Ctr+14, "Left",LB, 7,1, Col,RGB(GRAY)
  
  TEXT X_Ctr+5,Y_Ctr+5,Chr$(131),LB,8,1,Col,RGB(GRAY)   'Right "
  TEXT X_Ctr+15, Y_Ctr+4, "Rotate",LB, 7,1, Col,RGB(GRAY)
  TEXT X_Ctr+15, Y_Ctr+14, "Right",LB, 7,1, Col,RGB(GRAY)
  
  BOX X_Ctr - 100, Y_Ctr - 25, 50, 20,,Col, RGB(GRAY)   'Space bar
  TEXT X_Ctr-75, Y_Ctr-15, "Thrust",CM, 7,1,Col,RGB(GRAY)
  
  TEXT X_Vol+20+10, Y_Vol+28, "+ Up", LB, 7,1,Col,RGB(GRAY)   'Sound level adjust
  TEXT X_Vol+20+10, Y_Vol+38, "- Down", LB, 7,1,Col,RGB(GRAY)
  BOX X_Vol+17+10, Y_Vol+18,11,10,,Col
  BOX X_Vol+17+10, Y_Vol+29,11,10,,Col
  
  IF NOT Show_Help THEN TEXT MM.HRES-10,Y_CTR+28,"Press [H|h] for HELP.","RB",7,1, RGB(Yellow), RGB(GRAY)
END SUB 'Help
  
SUB DrawMoon
  LOCAL INTEGER i
  FOR i = 0 TO MM.HRES-1
    IF i > xpad AND i < xpad + Padwidth THEN
      LINE i,surface(i),i,MM.VRES-1,1,rgb(GRAY)
      LINE i,surface(i),i,surface(i),1,rgb(green) 'landing pad
    ELSE
      LINE i,surface(i),i,MM.VRES-1,1,rgb(GRAY)
      IF surface(i+1) > surface(i) THEN   'This adds sunlight to the lunar surface
        LINE i, surface(i), i+1, surface(i+1),,RGB(Yellow)
      ELSE
        LINE i, surface(i), i+1, surface(i+1),,RGB(GRAY)
      END IF
    END IF
  NEXT i
  
  Help
  
  'Show Instruments:
  '  X_Vol = 550             'Volume/Sound controls
  '  Y_Vol = Y_Ctr
  '  Y_H = 52
  BOX X_Vol, Y_Vol-Y_H, 10, Y_H,,RGB(WHITE), RGB(BLACK)
  TEXT X_Vol+6, Y_Vol+28, "SOUND", CB, 7,1,RGB(WHITE),RGB(GRAY)
  
  '  X_Fuel = 450        'Fuel gauge X location
  '  Y_Fuel = Y_Ctr      '
  '  H_Fuel = 52
  BOX X_Fuel, Y_Fuel-H_Fuel, 10, H_Fuel,,RGB(WHITE), RGB(BLACK)
  TEXT X_Fuel+6, Y_Fuel+28, "FUEL", CB, 7,1,RGB(WHITE),RGB(GRAY)
  
  '  X_Hzt = 325             'Horizontal speedometer X location
  '  Y_Hzt = Y_Ctr
  TEXT X_Hzt+6, Y_Vol+28, "HORIZONTAL", CB, 7,1,RGB(WHITE),RGB(GRAY)
  TEXT X_Hzt+6, Y_Vol+38, "VELOCITY", CB, 7,1,RGB(WHITE),RGB(GRAY)
  'ARC x, y, r1, [r2], rad1, rad2, Colour
  ARC X_Hzt, Y_Hzt, 40, 50, 270, 90, RGB(BLACK)   'Blank out gauge
  ARC X_Hzt, Y_Hzt, 40, , 270, 90, RGB(WHITE)
  ARC X_Hzt, Y_Hzt, 50, , 270, 90, RGB(WHITE)
  LINE X_Hzt-50,Y_Hzt,X_Hzt-40,Y_Hzt, ,RGB(WHITE)
  LINE X_Hzt+50,Y_Hzt,X_Hzt+40,Y_Hzt, ,RGB(WHITE)
  LINE X_Hzt,Y_Hzt-50,X_Hzt,Y_Hzt-40, ,RGB(WHITE) 'Centre bar
  TEXT X_Hzt-45,Y_Hzt+10, "-90", CB,7,1,RGB(WHITE),RGB(GRAY)
  TEXT X_Hzt+45,Y_Hzt+10, "+90", CB,7,1,RGB(WHITE),RGB(GRAY)
  
  '  X_Vert = 150             'Vertical speedometer
  '  Y_Vert = Y_Ctr -15      '25  '-50
  TEXT X_Vert, Y_Vert+5,  "VERTICAL", CB, 7,1,RGB(WHITE),RGB(GRAY)
  TEXT X_Vert, Y_Vert+15, "VELOCITY", CB, 7,1,RGB(WHITE),RGB(GRAY)
  ARC X_Vert, Y_Vert, 40,50,0, 180, RGB(BLACK)   'Blank out gauge
  ARC X_Vert, Y_Vert, 40,  ,0, 180, RGB(WHITE)
  ARC X_Vert, Y_Vert, 50,  ,0, 180, RGB(WHITE)
  LINE X_Vert, Y_Vert-40, X_Vert, Y_Vert-50,, RGB(WHITE)
  LINE X_Vert, Y_Vert+40, X_Vert, Y_Vert+50,, RGB(WHITE)
  LINE X_Vert+40, Y_Vert, X_Vert+50, Y_Vert,, RGB(WHITE)'Centre bar
  TEXT X_Vert-15, Y_Vert-40, "+90", CB, 7,1,RGB(WHITE),RGB(GRAY)
  TEXT X_Vert-15, Y_Vert+50, "-90", CB, 7,1,RGB(WHITE),RGB(GRAY)
END SUB	'DrawMoon
  
  '***********************************
SUB CreateMoon
  LOCAL height
  LOCAL INTEGER i
  
  fuel = StartFuel
  
  xpad = INT(RND * 400) + 200 - Padwidth/2
  height = 500 - INT(RND * 100)  ' landing pad altitude
  
  FOR i = 0 TO Padwidth
    surface(xpad + i) = height
  NEXT i
  
  FOR i = xpad-1 TO 0 step -1
    surface(i) = surface(i+1) + 4.8 - 10*rnd  ' slight bias up
    IF surface(i) > MM.VRES-75 THEN surface(i) = MM.VRES-75
  NEXT i
  
  FOR i = xpad + Padwidth TO MM.HRES
    surface(i) = surface(i-1) + 4.8 - 10*rnd  ' slight bias up
    IF surface(i) > MM.VRES-75 THEN surface(i) = MM.VRES-75
  NEXT i
end sub 'CreateMoon
  
  '***********************************
SUB DrawStars
  LOCAL INTEGER i
  FOR i = 1 TO 200
    PIXEL 800*RND,500*RND,MAP(RND*255)
  NEXT i  
END SUB	'DrawStars
  
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