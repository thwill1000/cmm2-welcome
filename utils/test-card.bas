' Test card for CMM2
' Author: "TassyJim", August 2020
' Support for modes 10, 11 and 12 added September 2020

  OPTION EXPLICIT
  OPTION DEFAULT NONE

  #Include "../common/welcome.inc"

  DIM INTEGER wd, ht, wbox, sh, x, w, n, nn, m, mp, cd, maxMode, keepMode
  DIM FLOAT a, defaultMode
  DIM k$, imgtitle$, fname$, imgRes$, pages$
  DIM INTEGER c(8)
  c(0) = RGB(BLACK)
  c(1) = RGB(YELLOW)
  c(2) = RGB(CYAN)
  c(3) = RGB(GREEN)
  c(4) = RGB(MAGENTA)
  c(5) = RGB(RED)
  c(6) = RGB(BLUE)
  c(7) = RGB(WHITE)
  c(8) = RGB(64,64,64)

  maxMode = 12
  cd = 8
  a = 1
  defaultMode = MM.INFO(MODE)
  mp = MM.INFO(MAX PAGES)
  CLS

  DO
    IF m = 0 THEN
      MODE 1,8
      CLS
      TEXT 400,100, "Video mode test",cm,5,1
      TEXT 400,180, "Ratio = aspect ratio used in the circle command",cm,1,1
      TEXT 400,220, "Q to quit, P to save page as a BMP",cm,3,1
      TEXT 400,260, "Up Down arrow to change resolution",cm,3,1
      TEXT 400,300, "Left Right arrow to change colour depth",cm,3,1
      TEXT 400,340, "+ - to change circle aspect ratio",cm,3,1
    ELSE
      IF keepmode THEN ' only change resolution if needed
        keepmode = 0
      ELSE
        MODE m,cd
        mp = MM.INFO(MAX PAGES)
      ENDIF
      wd = MM.HRES : ht = MM.VRES
      nn = INT(wd/80)
      imgtitle$ =" MODE "+STR$(MM.INFO(MODE))+" Ratio "+STR$(a,1,3)+" "
      imgRes$ = " "+STR$(MM.HRES)+" x "+STR$(MM.VRES)+" "
      pages$ = " Maximum page number = "+str$(mp)+" "
      wbox = wd / 8
      IF mp > 0 THEN ' mode 11,16 and 12,16 only have page 0
        PAGE WRITE 1 ' no flicker during write
      ENDIF
      CLS
      ' primary colours
      FOR x = 0 TO 7
        BOX x*wbox,ht/4,wbox,ht/2,0,c(x), c(x)
      NEXT x
      ' full gradient for each primary colour and greyscale
      FOR x = 0 TO wd-1
        sh = 255*x/wd

        LINE x,0,x,ht/12,1,RGB(sh,0,0)
        LINE x,ht/12,x,ht/6,1,RGB(0,sh,0)
        LINE x,ht/6,x,ht/4,1,RGB(0,0,sh)

        LINE x,ht*9/12,x,ht*10/12,1,RGB(0,sh,sh)
        LINE x,ht*10/12,x,ht*11/12,1,RGB(sh,0,sh)
        LINE x,ht*11/12,x,ht,1,RGB(sh,sh,0)

        LINE x,ht/2,x,ht*3/4,1,RGB(sh,sh,sh) ' greyscale
      NEXT x
      ' circle to check aspect ratio
      CIRCLE wd/2,ht/2, ht*15/32,3,a,c(7)
      sh = 0
      x = wd/2 - 55*nn/2
      ' black white bars to check monitor bandwidth
      FOR w = 10 TO 1 STEP -1
        FOR n = 1 TO nn
          sh = 255 - sh
          LINE x,ht*3/8,x,ht*5/8,w,RGB(sh,sh,sh)
          x = x + w
        NEXT n
      NEXT w
      ' white and red border to check that image fits on monitor
      BOX 0,0,wd,ht,3,c(7)
      BOX 1,1,wd-2,ht-2,1,c(5)
      ' title
      IF wd > 600 THEN
        TEXT wd/2,ht/2-15, imgtitle$,cm,4,1
        TEXT wd/2,ht/2, pages$,cm,4,1
        TEXT wd/2,ht/2+15, imgRes$,cm,4,1
      ELSE
        TEXT wd/2,ht/2-11, imgtitle$,cm,1,1
        TEXT wd/2,ht/2, pages$,cm,1,1
        TEXT wd/2,ht/2+11, imgRes$,cm,1,1
      ENDIF
      ' show the new image
      IF m < 11 OR cd = 8 THEN
        PAGE COPY 1 TO 0 ,B
      ENDIF
    ENDIF

    Do While Inkey$ <> "" : Loop ' clear keyboard buffer
    Do : k$ = Inkey$ : Loop Until k$ <> "" ' wait for keypress

    SELECT CASE k$
      CASE "Q","q"
        EXIT DO
      CASE "P","p"
        fname$ = MID$(imgtitle$,2)+".bmp"
        TIMER = 0
        SAVE IMAGE fname$
        PAGE WRITE 0
        TEXT wd/2,ht/2,"Saved as "+fname$+" in "+STR$(TIMER/1000,3,2)+" Sec" ,cm,1,1
        DO
          k$ = INKEY$
        LOOP UNTIL k$<>""
      CASE CHR$(128) ' up arrow
        m = m - 1
        IF m < 1 THEN m = maxMode
        IF (m = 9 OR m = 11 OR m = 12) AND cd = 12 THEN cd = 8 ' skip 12 bit for mode 9 11 12
      CASE CHR$(129) ' down arrow
        m = m + 1
        IF m > maxMode THEN m = 1
        IF (m = 9 OR m = 11 OR m = 12) AND cd = 12 THEN cd = 8 ' skip 12 bit for mode 9 11 12
      CASE CHR$(131) ' right arrow res up
        cd = cd + 4
        IF cd > 16 THEN cd = 8
        IF (m = 9 OR m = 11 OR m = 12) AND cd = 12 THEN cd = 16 ' skip 12 bit for mode 9 11 12
      CASE CHR$(130) ' left arrow  res down
        cd = cd - 4
        IF cd < 8 THEN cd = 16
        IF (m = 9 OR m = 11 OR m = 12) AND cd = 12 THEN cd = 8 ' skip 12 bit for mode 9 11 12
      CASE "+" ' ratio plus
        IF a < 1.4 THEN a = a + 0.01
        keepmode = 1
      CASE "-" ' ratio minus
        IF a > 0.75 THEN a = a - 0.01
        keepmode = 1
      CASE ELSE ' same as down arrow
        m = m + 1
        IF m > maxMode THEN m = 1
    END SELECT
  LOOP
  setmode defaultMode ' restore original mode before ending program
  PAGE WRITE 0
  CLS

we.end_program()

SUB setmode dotMode AS FLOAT
  LOCAL INTEGER mm, md
  ' use float returned by mm.info(mode) to set MODE
  mm = INT(dotmode)
  md = (dotmode - mm)*100
  IF md > 20 THEN md = md/10
  MODE mm, md
END SUB
