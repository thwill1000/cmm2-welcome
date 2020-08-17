 ' John Conway's Game of Life for Micromite MMBasic
 ' Bill McKinley
 ' adapted by TassyJim
 
 DIM Bx$
 DIM INTEGER MatX = 40   ' Matrix horizontal size
 DIM MatY   ' Matrix vertical size - gets calculated later depending on screen size
 DIM FLOAT RandL = 0.3 ' For random life. less than =< RandL means there is life
 ' Make it high and you get a lot of cells but they die quickly
 DIM PT = 000    ' Pause time in mS between display updates
 DIM INTEGER initialPause = 3000 ' time to display starting pattern
 DIM INTEGER DIAM, a, b = 1, gen
 DIM INTEGER dying, dyingOn = RGB(127,0,0)
 DIM INTEGER wrap
 DIM FLOAT rate
 
 DIAM = MM.HRES/matX
 MatY = INT( MatX *MM.VRES/MM.HRES)
 
 ' Zero based matrix has one more cell all round than is displayed
 DIM M(MatX+1, MatY+1,2) ' The  matrix of life
 DO
   ChkScr      ' Print intro
   IF Bx$ = "Q" OR Bx$ = "q" THEN EXIT DO
   CLS
   InitM       ' Initialize the random matrix (or demo)
   initial_gen
   PAUSE initialPause
   TIMER = 0  ' reset for next timer
   DO          ' Program loop
     NextGen     ' Calculate the next generation
     PAUSE PT
     rate = TIMER - PT
     TIMER = 0
   LOOP UNTIL INKEY$ <> "" ' loop forever or until a keypres
 LOOP
 
SUB ChkScr ' Print intro
 DO
   CLS
   PRINT "   CONWAY'S GAME OF LIFE"
   PRINT
   PRINT "   Press a key to start "
   PRINT "   and another to stop  "
   PRINT "     W to wrap display  "
   PRINT "      0-9 for a demo    "
   PRINT "        Q to quit       "
   DO
     Bx$ = INKEY$
   LOOP UNTIL Bx$ <> ""
   IF Bx$ = "W" OR Bx$ = "w" THEN ' toggle display wrapping
     wrap = 1 - wrap
   ENDIF
 LOOP UNTIL Bx$ <> "W" AND Bx$ <> "w" ' loop if last command was toggle wrap
END SUB
 
SUB InitM ' Initialise the matrix of life
 LOCAL INTEGER x,y
 FOR y = 1 TO MatY
   FOR x = 1 TO MatX
     M(x, y, b) = 0
   NEXT x
 NEXT y
 x = 0
 rate = 0
 gen = 0
 SELECT CASE Bx$
   CASE "1" ' glider
     RESTORE seed1
   CASE "2" ' blinker
     RESTORE seed2
   CASE "3" ' toad
     RESTORE seed3
   CASE "4" ' beacon
     RESTORE seed4
   CASE "5" 'Penta-decathlon
     RESTORE seed5
   CASE "6" ' pulsar
     RESTORE seed6
   CASE "7" '
     RESTORE seed7
   CASE "8" '
     RESTORE seed8
   CASE "9" '
     RESTORE seed9
   CASE "0" ' diehard
     RESTORE seed0
   CASE "Q","q" ' do nothing
     x = -1
   CASE ELSE ' random set
     FOR y = 2 TO MatY-1
       FOR x = 2 TO MatX-1
         IF RND() <= RandL THEN
           M(x, y, b) = 1
         ELSE
           M(x, y, b) = 0
         ENDIF
       NEXT x
     NEXT y
     dying = dyingOn
 END SELECT
 IF x = 0 THEN ' we need to read a set configuration
   DO
     READ x
     READ y
     IF x = -1 THEN EXIT DO
     IF y = -1 THEN PRINT "Error in Data",x,y: EXIT DO
     M(x, y, b) = 1
   LOOP
   dying = y*dyingOn
 ENDIF
END SUB
 
SUB initial_gen
 FOR y = 1 TO MatY
   FOR x = 1 TO MatX
     IF M(x, y, b) = 1 THEN
       draw_cell(x, y, RGB(YELLOW))
     ENDIF
   NEXT x
 NEXT y
END SUB
 
SUB NextGen ' Breed the next generation
 LOCAL INTEGER x, y, d, i
 a = 1 - a
 b = 1 - a
 gen = gen + 1
 
 IF wrap = 1 THEN
   ' wrap the corners
   M(0,0, a) = M(MatX,MatY, a)
   M(MatX+1,MatY+1, a) = M(1,1, a)
   M(0,MatY+1, a) = M(MatX,1, a)
   M(MatX+1,0, a) = M(1,MatY, a)
   ' wrap the edges
   FOR i = 1 TO MatX
     M(i,0, a) = M(i,MatY, a) ' top
     M(i,MatY+1, a) = M(i,1, a) ' bottom
   NEXT i
   FOR i = 1 TO MatY
     M(0,i, a) = M(MatX,i, a) ' left
     M(matX+1,i, a) = M(1,i, a) ' right
   NEXT i
 ENDIF
 FOR y = 1 TO MatY
 IF y = 2 THEN TEXT 1,1,STR$(gen,10)+" "+STR$(rate,5,0)
   FOR x = 1 TO MatX
     d = M(x-1,y-1,a) + M(x-1,y,a) + M(x-1,y+1,a)
     d = d + M(x,y-1,a) + M(x,y+1, a)
     d = d + M(x+1,y-1,a) + M(x+1,y,a) + M(x+1,y+1,a)
     d = d MOD 10
     IF M(x,y,a) = 1 THEN
       IF d = 2 OR d = 3 THEN
         draw_cell(x,y, RGB(GREEN))
         M(x,y,b) = 1
       ELSE
         draw_cell(x,y, dying)
         M(x,y, b) = 10 ' flag this cell to be cleared next generation
       ENDIF
     ELSE
       IF d = 3 THEN
         draw_cell(x,y, RGB(YELLOW))
         M(x,y,b) = 1
       ELSE
         IF M(x,y,a) = 10 THEN draw_cell(x,y, 0)
         M(x,y,b) = 0
       ENDIF
     ENDIF
   NEXT x
 NEXT y
END SUB
 
SUB draw_cell(x, y, col)
 CIRCLE (x - 0.5) * DIAM, (y - 0.5) * DIAM, DIAM/2 - 2, 1,,col, col
 'text x * DIAM, y * DIAM,"O","LT",1,1,col ', col
END SUB
 
 ' seeds are pairs of x,y cells ending in -1 then 0 or 1 for coloured dying cells
seed1: ' glider
 DATA 4,7,5,7,6,7,6,6,5,5,-1,0
seed2: ' blinker
 DATA 4,7,5,7,6,7,-1,0
seed3: ' toad
 DATA 5,7,6,7,7,7,4,8,5,8,6,8,-1,0
seed4: ' beacon
 DATA 4,7,5,7,4,8,7,9,6,10,7,10,-1,0
seed5: 'Penta-decathlon
 DATA 5, 7,6, 7,7, 7,5, 8,7, 8,5, 9,6, 9,7, 9
 DATA 5, 10,6, 10,7, 10,5, 11,6, 11,7, 11,5, 12
 DATA 6, 12,7, 12,5, 13,7, 13,5, 14,6, 14,7, 14,-1,1
seed6: ' pulsar
 DATA 5,3,6,3,7,3,11,3,12,3,13,3,3,5,8,5,10,5,15,5
 DATA 3,6,8,6,10,6,15,6,3,7,8,7,10,7,15,7
 DATA 5,8,6,8,7,8,11,8,12,8,13,8,5,10,6,10,7,10,11,10,12,10,13,10
 DATA 3,11,8,11,10,11,15,11,3,12,8,12,10,12,15,12
 DATA 3,13,8,13,10,13,15,13,5,15,6,15,7,15,11,15,12,15,13,15
 DATA -1, 1
seed7: ' LW spaceship
 DATA 3,2,6,2,7,3,3,4,7,4,4,5,5,5,6,5,7,5,-1,1
seed8: ' MW spaceship
 DATA 5,2,3,3,7,3,8,4,3,5,8,5,4,6,5,6,6,6,7,6,8,6,-1,1
seed9: ' HW spaceship
 DATA 7,4,8,4,3,5,4,5,5,5,6,5,8,5,9,5,3,6,4,6,5,6,6,6,7,6,8,6
 DATA 4,7,5,7,6,7,7,7,-1,1
seed0:  'diehard
 DATA 8,5,2,6,3,6,4,6,7,7,8,7,9,7,-1,1
