#INCLUDE "../common/welcome.inc"

Intro$="Welcome to the Colour Maximite 2"
Prompt$="Please enter something for me to speak, or Q to exit"

PhoneticOn=0
Speed=72
Pitch=64

MODE 3,8
CLS
we.clear_keyboard_buffer()

PRINT "Speech - Instructions"
PRINT
PRINT "Enter something for the computer to say, or one of these commands:"
PRINT "Q - Quit"
PRINT "*phonetic on|off"
PRINT "*speed <value> - choose a speed from 1-255"
PRINT "*pitch <value> - choose a pitch from 1-255"
PRINT "*config - to list the current parameters"
PRINT

PLAY TTS Intro$ + " " + Prompt$
PRINT Intro$
DO
        INPUT Prompt$;Answer$
Test:   IF Answer$="Q" OR Answer$="q" THEN END

        UpAnswer$ = UPPER$(Answer$)
        IF UpAnswer$ = "*PHONETIC ON" THEN
          PhoneticOn = 1
        ELSE IF UpAnswer$ = "*PHONETIC OFF" THEN
          PhoneticOn = 0
        ELSE IF LEFT$(UpAnswer$,6) = "*SPEED" THEN
          String2$=MID$(UpAnswer$,7)
          Speed=VAL(String2$)
        ELSE IF LEFT$(UpAnswer$,6) = "*PITCH" THEN
          String2$=MID$(UpAnswer$,7)
          Pitch=VAL(String2$)
        ELSE IF LEFT$(UpAnswer$,7) = "*CONFIG" THEN
          IF PhoneticOn THEN
            PRINT "Phonetic ON"
          ELSE
            PRINT "Phonetic OFF"
          PRINT "Pitch: ";Pitch
          PRINT "Speed: ";Speed
        ELSE
          IF PhoneticOn THEN
            PLAY TTS PHONETIC Answer$,Speed,Pitch
          ELSE
            PLAY TTS Answer$,Speed,Pitch
        ENDIF
LOOP

we.end_program()
                                                
