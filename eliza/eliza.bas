' Authors: Patricia Danielson, Paul Hashfield, "vegipete"
'          and no doubt innumerable others over the years

#Include "../common/welcome.inc"

10 CLS
11 XV = 300
12 YV = 40
13 TEXT XV,YV,"**************************","CT"
14 YV = YV + 15
15 TEXT XV,YV,"ELIZA","CT"
16 YV = YV + 15
17 TEXT XV,YV,"CREATIVE COMPUTING","CT"
18 YV = YV + 15
19 TEXT XV,YV,"MORRISTOWN, NEW JERSEY","CT"
20 YV = YV + 15
21 TEXT XV,YV,"ADAPTED FOR IBM PC BY","CT"
22 YV = YV + 15
23 TEXT XV,YV,"PATRICIA DANIELSON AND PAUL HASHFIELD","CT"
24 YV = YV + 15
  TEXT XV,YV,"ADAPTED SLIGHTLY FOR CMM2 BY","CT"
  YV = YV + 15
  TEXT XV,YV,"VEGIPETE, AUGUST 2020","CT"
  YV = YV + 15
25 YV = YV + 15
26 TEXT XV,YV,"HAVE ANY PROBLEMS ?","CT"
27 YV = YV + 15
28 TEXT XV,YV,"LET ELIZA HELP YOU !","CT"
29 YV = YV + 15
30 YV = YV + 15
31 TEXT XV,YV,"TO STOP ELIZA TYPE 'SHUT UP'","CT"
32 YV = YV + 15
34 YV = YV + 15
35 TEXT XV,YV,"PLEASE DON'T USE COMMAS OR PERIODS IN YOUR INPUTS","CT"
36 YV = YV + 15
37 YV = YV + 15
38 TEXT XV,YV,"< PRESS A KEY TO CONTINUE...>","CT"
39 DO : LOOP UNTIL INKEY$ <> ""
40 PRINT : PRINT : PRINT
80  REM*****INITIALIZATION**********
100 DIM S(36),R(36),N(36)
105 DIM KEYWORD$(36),WORDIN$(7),WORDOUT$(7),REPLIES$(112)
110 N1=36:N2=14:N3=112
112 FOR X = 1 TO N1: READ KEYWORD$(X): NEXT X
114 FOR X = 1 TO N2/2: READ WORDIN$(X):READ WORDOUT$(X): NEXT X
116 FOR X = 1 TO N3: READ REPLIES$(X): NEXT X
130 FOR X=1 TO N1
140 READ S(X),L:R(X)=S(X):N(X)=S(X)+L-1
150 NEXT X
160 PRINT "HI! I'M ELIZA. WHAT'S YOUR PROBLEM?"
170 REM ***********************************
180 REM *******USER INPUT SECTION**********
190 REM ***********************************
200 INPUT I$
201 I$="  "+UCASE$(I$)+"  "
210 REM GET RID OF APOSTROPHES
220 FOR L=1 TO LEN(I$)
230 REM IF MID$(I$,L,1)="'"THEN I$=LEFT$(I$,L-1)+RIGHT$(I$,LEN(I$)-L):GOTO 230
240 IF L+4>LEN(I$)THEN 250
241 IF MID$(I$,L,4) <> "SHUT" THEN 250
242 PRINT "O.K. IF YOU FEEL THAT WAY I'LL SHUT UP...."
Pause 2000
we.end_program()
250 NEXT L
255 IF I$=P$ THEN PRINT "PLEASE DON'T REPEAT YOURSELF!":GOTO 170
260 REM ***********************************
270 REM ********FIND KEYWORD IN I$*********
280 REM ***********************************
300 FOR K=1 TO N1
320 FOR L=1 TO LEN (I$)-LEN (KEYWORD$(K))+1
340 IF MID$(I$,L,LEN(KEYWORD$(K)))<>KEYWORD$(K) THEN 350
341 IF K <> 13 THEN 349
342 IF MID$(I$,L,LEN(KEYWORD$(29)))=KEYWORD$(29) THEN K = 29
349 F$ = KEYWORD$(K): GOTO 390
350 NEXT L
360 NEXT K
370 K=36: GOTO 570:REM WE DIDN'T FIND ANY KEYWORDS
380 REM ******************************************
390 REM **TAKE PART OF STRING AND CONJUGATE IT****
400 REM **USING THE LIST OF STRINGS TO BE SWAPPED*
410 REM ******************************************
430 C$=" "+RIGHT$(I$,LEN(I$)-LEN(F$)-L+1)+" "
440 FOR X=1 TO N2/2
460 FOR L=1 TO LEN(C$)
470 IF L+LEN(WORDIN$(X))>LEN(C$) THEN 510
480 IF MID$(C$,L,LEN(WORDIN$(X)))<>WORDIN$(X) THEN 510
490 C$=LEFT$(C$,L-1)+WORDOUT$(X)+RIGHT$(C$,LEN(C$)-L-LEN(WORDIN$(X))+1)
495 L = L+LEN(WORDOUT$(X))
500 GOTO 540
510 IF L+LEN(WORDOUT$(X))>LEN(C$)THEN 540
520 IF MID$(C$,L,LEN(WORDOUT$(X)))<>WORDOUT$(X) THEN 540
530 C$=LEFT$(C$,L-1)+WORDIN$(X)+RIGHT$(C$,LEN(C$)-L-LEN(WORDOUT$(X))+1)
535 L=L+LEN(WORDIN$(X))
540 NEXT L
550 NEXT X
555 IF MID$(C$,2,1)=" "THEN C$=RIGHT$(C$,LEN(C$)-1):REM ONLY 1 SPACE
556 FOR L=1 TO LEN(C$)
557 IF MID$(C$,L,1)="!" THEN C$=LEFT$(C$,L-1)+RIGHT$(C$,LEN(C$)-L):GOTO 557
558 NEXT L
560 REM **********************************************
570 REM **NOW USING THE KEYWORD NUMBER (K) GET REPLY**
580 REM **********************************************
600 F$ = REPLIES$(R(K))
610 R(K)=R(K)+1:IF R(K)>N(K) THEN R(K)=S(K)
620 IF RIGHT$(F$,1)<>"*" THEN PRINT F$:P$=I$:GOTO 170
625 IF C$<>"   " THEN 630
626 PRINT "YOU WILL HAVE TO ELABORATE MORE FOR ME TO HELP YOU"
627 GOTO 170
630 PRINT LEFT$(F$,LEN(F$)-1);C$
640 P$=I$:GOTO 170
1000 REM *******************************
1010 REM *****PROGRAM DATA FOLLOWS******
1020 REM *******************************
1030 REM *********KEYWORDS**************
1049 REM *******************************
1050 DATA "CAN YOU ","CAN I ","YOU ARE ","YOU'RE ","I DON'T ","I FEEL "
1060 DATA "WHY DON'T YOU ","WHY CAN'T I ","ARE YOU ","I CAN'T ","I AM ","I'M "
1070 DATA "YOU ","I WANT ","WHAT ","HOW ","WHO ","WHERE ","WHEN ","WHY "
1080 DATA "NAME ","CAUSE ","SORRY ","DREAM ","HELLO ","HI ","MAYBE "
1090 DATA "NO","YOUR ","ALWAYS ","THINK ","ALIKE ","YES ","FRIEND "
1100 DATA "COMPUTER", "NOKEYFOUND"
1200 REM *********************************
1210 REM ***STRING DATA FOR CONJUGATIONS**
1220 REM *********************************
1230 DATA " ARE "," AM "," WERE "," WAS "," YOU "," I "," YOUR"," MY "
1235 DATA " I'VE "," YOU'VE "," I'M "," YOU'RE "
1240 DATA " ME "," YOU "
1300 REM ******************************
1310 REM *********REPLIES**************
1320 REM ******************************
1330 DATA "DON'T YOU BELIEVE THAT I CAN*"
1340 DATA "PERHAPS YOU WOULD LIKE TO BE LIKE ME*"
1350 DATA "YOU WANT ME TO BE ABLE TO*"
1360 DATA "PERHAPS YOU DON'T WANT TO*"
1365 DATA "DO YOU WANT TO BE ABLE TO*"
1370 DATA "WHAT MAKES YOU THINK I AM*"
1380 DATA "DOES IT PLEASE YOU TO BELIEVE I AM*"
1390 DATA "PERHAPS YOU WOULD LIKE TO BE*"
1400 DATA "DO YOU SOMETIMES WISH YOU WERE*"
1410 DATA "DON'T YOU REALLY*"
1420 DATA "WHY DON'T YOU*"
1430 DATA "DO YOU WISH TO BE ABLE TO*"
1440 DATA "DOES THAT TROUBLE YOU*"
1450 DATA "DO YOU OFTEN FEEL*"
1460 DATA "DO YOU OFTEN FEEL*"
1470 DATA "DO YOU ENJOY FEELING*"
1480 DATA "DO YOU REALLY BELIEVE I DON'T*"
1490 DATA "PERHAPS IN GOOD TIME I WILL*"
1500 DATA "DO YOU WANT ME TO*"
1510 DATA "DO YOU THINK YOU SHOULD BE ABLE TO*"
1520 DATA "WHY CAN'T YOU*"
1530 DATA "WHY ARE YOU INTERESTED IN WHETHER OR NOT I AM*"
1540 DATA "WOULD YOU PREFER IF I WERE NOT*"
1550 DATA "PERHAPS IN YOUR FANTASIES I AM*"
1560 DATA "HOW DO YOU KNOW YOU CAN'T*"
1570 DATA "HAVE YOU TRIED?"
1580 DATA "PERHAPS YOU CAN NOW*"
1590 DATA "DID YOU COME TO ME BECAUSE YOU ARE*"
1600 DATA "HOW LONG HAVE YOU BEEN*"
1610 DATA "DO YOU BELIEVE IT IS NORMAL TO BE*"
1620 DATA "DO YOU ENJOY BEING*"
1630 DATA "WE WERE DISCUSSING YOU--NOT ME."
1640 DATA "OH, I*"
1650 DATA "YOU'RE NOT REALLY TALKING ABOUT ME, ARE YOU?"
1660 DATA "WHAT WOULD IT MEAN TO YOU IF YOU GOT*"
1670 DATA "WHY DO YOU WANT*"
1680 DATA "SUPPOSE YOU SOON GOT*"
1690 DATA "WHAT IF YOU NEVER GOT*"
1700 DATA "I SOMETIMES ALSO WANT*"
1710 DATA "WHY DO YOU ASK?"
1720 DATA "DOES THAT QUESTION INTEREST YOU?"
1730 DATA "WHAT ANSWER WOULD PLEASE YOU THE MOST?"
1740 DATA "WHAT DO YOU THINK?"
1750 DATA "ARE SUCH QUESTIONS ON YOUR MIND OFTEN?"
1760 DATA "WHAT IS IT THAT YOU REALLY WANT TO KNOW?"
1770 DATA "HAVE YOU ASKED ANYONE ELSE?"
1780 DATA "HAVE YOU ASKED SUCH QUESTIONS BEFORE?"
1790 DATA "WHAT ELSE COMES TO MIND WHEN YOU ASK THAT?"
1800 DATA "NAMES DON'T INTEREST ME."
1810 DATA "I DON'T CARE ABOUT NAMES --PLEASE GO ON."
1820 DATA "IS THAT THE REAL REASON?"
1830 DATA "DON'T ANY OTHER REASONS COME TO MIND?"
1840 DATA "DOES THAT REASON EXPLAIN ANYTHING ELSE?"
1850 DATA "WHAT OTHER REASONS MIGHT THERE BE?"
1860 DATA "PLEASE DON'T APOLOGIZE!"
1870 DATA "APOLOGIES ARE NOT NECESSARY."
1880 DATA "WHAT FEELINGS DO YOU HAVE WHEN YOU APOLOGIZE?"
1890 DATA "DON'T BE SO DEFENSIVE!"
1900 DATA "WHAT DOES THAT DREAM SUGGEST TO YOU?"
1910 DATA "DO YOU DREAM OFTEN?"
1920 DATA "WHAT PERSONS APPEAR IN YOUR DREAMS?"
1930 DATA "ARE YOU DISTURBED BY YOUR DREAMS?"
1940 DATA "HOW DO YOU DO ...PLEASE STATE YOUR PROBLEM."
1950 DATA "YOU DON'T SEEM QUITE CERTAIN."
1960 DATA "WHY THE UNCERTAIN TONE?"
1970 DATA "CAN'T YOU BE MORE POSITIVE?"
1980 DATA "YOU AREN'T SURE?"
1990 DATA "DON'T YOU KNOW?"
2000 DATA "ARE YOU SAYING NO JUST TO BE NEGATIVE?"
2010 DATA "YOU ARE BEING A BIT NEGATIVE."
2020 DATA "WHY NOT?"
2030 DATA "ARE YOU SURE?"
2040 DATA "WHY NO?"
2050 DATA "WHY ARE YOU CONCERNED ABOUT MY*"
2060 DATA "WHAT ABOUT YOUR OWN*"
2070 DATA "CAN YOU THINK OF A SPECIFIC EXAMPLE?"
2080 DATA "WHEN?"
2090 DATA "WHAT ARE YOU THINKING OF?"
2100 DATA "REALLY, ALWAYS?"
2110 DATA "DO YOU REALLY THINK SO?"
2120 DATA "BUT YOU ARE NOT SURE YOU*"
2130 DATA "DO YOU DOUBT YOU*"
2140 DATA "IN WHAT WAY?"
2150 DATA "WHAT RESEMBLANCE DO YOU SEE?"
2160 DATA "WHAT DOES THE SIMILARITY SUGGEST TO YOU?"
2170 DATA "WHAT OTHER CONNECTIONS DO YOU SEE?"
2180 DATA "COULD THERE REALLY BE SOME CONNECTION?"
2190 DATA "HOW?"
2200 DATA "YOU SEEM QUITE POSITIVE."
2210 DATA "ARE YOU SURE?"
2220 DATA "I SEE."
2230 DATA "I UNDERSTAND."
2240 DATA "WHY DO YOU BRING UP THE TOPIC OF FRIENDS?"
2250 DATA "DO YOUR FRIENDS WORRY YOU?"
2260 DATA "DO YOUR FRIENDS PICK ON YOU?"
2270 DATA "ARE YOU SURE YOU HAVE ANY FRIENDS?"
2280 DATA "DO YOU IMPOSE ON YOUR FRIENDS?"
2290 DATA "PERHAPS YOUR LOVE FOR FRIENDS WORRIES YOU."
2300 DATA "DO COMPUTERS WORRY YOU?"
2310 DATA "ARE YOU TALKING ABOUT ME IN PARTICULAR?"
2320 DATA "ARE YOU FRIGHTENED BY MACHINES?"
2330 DATA "WHY DO YOU MENTION COMPUTERS?"
2340 DATA "WHAT DO YOU THINK MACHINES HAVE TO DO WITH YOUR PROBLEM?"
2350 DATA "DON'T YOU THINK COMPUTERS CAN HELP PEOPLE?"
2360 DATA "WHAT IS IT ABOUT MACHINES THAT WORRIES YOU?"
2370 DATA "SAY, DO YOU HAVE ANY PSYCHOLOGICAL PROBLEMS?"
2380 DATA "WHAT DOES THAT SUGGEST TO YOU?"
2390 DATA "I SEE."
2400 DATA "I'M NOT SURE I UNDERSTAND YOU FULLY."
2410 DATA "COME COME ELUCIDATE YOUR THOUGHTS."
2420 DATA "CAN YOU ELABORATE ON THAT?"
2430 DATA "THAT IS QUITE INTERESTING."
2500  REM *************************
2510 REM *****DATA FOR FINDING RIGHT REPLIES
2520 REM *************************
2530 DATA 1,3,4,2,6,4,6,4,10,4,14,3,17,3,20,2,22,3,25,3
2540 DATA 28,4,28,4,32,3,35,5,40,9,40,9,40,9,40,9,40,9,40,9
2550 DATA 49,2,51,4,55,4,59,4,63,1,63,1,64,5,69,5,74,2,76,4
2560 DATA 80,3,83,7,90,3,93,6,99,7,106,6
