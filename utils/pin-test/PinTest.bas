'MMEDIT!!! Basic Version = CMM2
'MMEDIT!!! Port = COM14:115200:10,300
'MMEDIT!!! Device = CMM2
'MMEDIT!!! Config = 1001111011200100100200000100010
  ' CMM2 pin tester.
  ' requires a bank of 28 same size resistors (I used 220 ohm)
  ' connected from each pin in pintest() array to a common point

#Include "../../common/welcome.inc"

  DIM pintest(27) = (3,5,7,11,13,15,19,21,23,27,29,31,33,35,37,8,10,12,16,18,22,24,26,28,32,36,38,40)
  DIM apins(11) = (7,13,15,29,37,8,10,12,16,22,24,26)
  DIM INTEGER k, bug
  DIM FLOAT v

  CLS

  PRINT : PRINT : PRINT :PRINT :PRINT
  FONT 5,2 : COLOUR RGB(YELLOW)
  PRINT "   PinTest.BAS";:PRINT : FONT 1:COLOUR RGB(MAGENTA): PRINT"                                                                 By TassyJim (edited by Bigmik)"
  FONT 2 : COLOUR RGB(CYAN)
  PRINT :PRINT :PRINT"        Used to test every IO pin for correct functionality"
  PRINT :PRINT :PRINT :PRINT :PRINT"  ";
  COLOUR RGB(RED),RGB(YELLOW)
  PRINT "Note!!!"
  COLOUR RGB(GREEN),RGB(BLACK)
  PRINT "  This program requires additional hardware to perform the tests!"
  PRINT : PRINT:PRINT:PRINT
  FONT 3
  PRINT "  Do you wish to see the hardware diagram? (Y/N)"
  FONT 2: PRINT "                   "; :COLOUR RGB(YELLOW),RGB(RED): PRINT "Viewed on VGA screen only"
  BOX 1,260,799,200,5,RGB(RED)

  clear_keyboard_buffer()
  key$ = wait_for_key$()

  IF UCase$(key$) = "Y" THEN
    LOAD GIF WE.PROG_DIR$ + "/40pin.gif"
    clear_keyboard_buffer()
    key$ = wait_for_key$()
  ENDIF

  COLOUR RGB(WHITE),RGB(BLACK):CLS:FONT 2
  PRINT :PRINT :PRINT
  PRINT "Please make sure the link is connected to the resistor on pin (40)"
  PRINT :PRINT:PRINT:PRINT"                 ";
  COLOUR RGB(BLACK),RGB(WHITE):PRINT " Press any key to continue"
  COLOUR RGB(WHITE),RGB(BLACK)

  clear_keyboard_buffer()
  key$ = wait_for_key$()

  FOR k = 0 TO 27 ' make sure all pins are floating
    SETPIN(pintest(k)), OFF
  NEXT k

  CLS
  ' read analog voltage with one pin gnd, all floating then one pin at 3.3V
  ' header wrong way around will give a narrow range of voltages ~1.16V
  PRINT
  PRINT "Testing for correct orientation"
  SETPIN 13, AIN
  SETPIN 3, DOUT
  PIN(3) = 0
  PRINT "Analog range from ";STR$(PIN(13),2,2);" > ";
  SETPIN 3, OFF
  PRINT STR$(PIN(13),2,2);" > ";
  SETPIN 3, DOUT
  PIN(3) = 1
  v = PIN(13)
  PRINT STR$(v,2,2)
  PRINT "A range from 0.2 to 2.9 is good."
  PRINT
  SETPIN 3, OFF
  SETPIN 13, OFF

  IF v < 2 THEN
    PRINT "It doesn't look right!!"
    PRINT "Giving up on the tests."
  ELSE
    PRINT "Testing Digital IN"
    ' toggle one pin high/low and check that each pin follows.
    SETPIN 40, DOUT
    FOR k = 0 TO 26
      testpin = pintest(k)
      SETPIN testpin , DIN
      PIN(40) = 1
      IF PIN(testpin ) <> 1 THEN PRINT "Pin ";testpin ;" failed DIN high" : bug = bug+1
      PIN(40) = 0
      IF PIN(testpin ) <> 0 THEN PRINT "Pin ";testpin ;" failed DIN low" : bug = bug+1
      SETPIN testpin , OFF
    NEXT k

    SETPIN 38, DOUT
    testpin = 40
    SETPIN testpin , DIN
    PIN(38) = 1
    IF PIN(testpin ) <> 1 THEN PRINT "Pin ";testpin ;" failed DIN high" : bug = bug+1
    PIN(38) = 0
    IF PIN(testpin ) <> 0 THEN PRINT "Pin ";testpin ;" failed DIN low" : bug = bug+1
    SETPIN testpin , OFF
    SETPIN 38, OFF

    PRINT
    PRINT "Testing Digital OUT"
    ' toggle each pin in turn and check that output follows.
    SETPIN 40, DIN
    FOR k = 0 TO 26
      testpin = pintest(k)
      SETPIN testpin , DOUT
      PIN(testpin) = 1
      IF PIN(40 ) <> 1 THEN PRINT "Pin ";testpin ;" failed DOUT high" : bug = bug+1
      PIN(testpin) = 0
      IF PIN(40 ) <> 0 THEN PRINT "Pin ";testpin ;" failed DOUT low" : bug = bug+1
      SETPIN testpin , OFF
    NEXT k

    SETPIN 38, DIN
    testpin = 40
    SETPIN testpin , DOUT
    PIN(testpin) = 1
    IF PIN(38 ) <> 1 THEN PRINT "Pin ";testpin ;" failed DOUT high" : bug = bug+1
    PIN(testpin) = 0
    IF PIN(38 ) <> 0 THEN PRINT "Pin ";testpin ;" failed DOUT low" : bug = bug+1
    SETPIN testpin , OFF
    SETPIN 38, OFF

    PRINT
    PRINT "Testing Analog IN"

    '  for k = 0 to 26
    'testpin = pintest(k)
    '  setpin testpin,din

    'next k

    ' testing analog in.
    ' set one pin high and one pin low to give VCC/2 at the common point.
    SETPIN 3, DOUT
    SETPIN 5, DOUT

    PIN(3) = 1
    PIN(5) = 0

    FOR n = 0 TO 11
      testpin = apins(n)
      SETPIN testpin, AIN
      v = PIN(testpin)
      IF V < 1.55 OR V > 1.75 THEN PRINT "Pin ";testpin ;" failed AIN - ";v : bug = bug+1
      SETPIN testpin, OFF
    NEXT n
    SETPIN 3, OFF
    SETPIN 5, OFF

    PRINT
    IF bug = 0 THEN
      PRINT "All tests completed with no errors"
      '     line 400,140,420,170,1,rgb(green):line 420,170,550,70,1,rgb(green)
      '    line 399,141,419,171,1,rgb(green):line 419,171,551,71,1,rgb(green)
      LOAD BMP WE.PROG_DIR$ + "/TICK.BMP" ,400,100
    ELSE
      PRINT "A total of ";bug; " errors detected over all tests!!!"
      LOAD BMP WE.PROG_DIR$ + "/CROSS.BMP" ,400,350
    ENDIF
  ENDIF
  PRINT

Print "                 ";
Colour RGB(Black), RGB(White)
Print " Press any key to exit "
Colour RGB(White), RGB(Black)
clear_keyboard_buffer()
key$ = wait_for_key$()
we.end_program()

Sub clear_keyboard_buffer()
  Do While Inkey$ <> "" : Loop
End Sub

Function wait_for_key$()
  Local k$
  Do : k$ = Inkey$ : Loop Until k$ <> ""
  wait_for_key$ = k$
End Function
