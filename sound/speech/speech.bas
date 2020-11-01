' Author: "capsikin"

#Include "../../common/welcome.inc"

PhoneticOn=0
Speed=72
Pitch=64

CLS
we.clear_keyboard_buffer()

SUB Instructions1
  PRINT "Speech - Instructions"
  PRINT
  PRINT "Enter something for the computer to say, or one of these commands:"
  PRINT "Q - Quit"
  PRINT "*phonetic on|off"
  PRINT "*speed <value> - choose a speed from 1-255"
  PRINT "*pitch <value> - choose a pitch from 1-255"
  PRINT "*config - to list the current parameters"
  PRINT "*help - full instructions"
  PRINT
END SUB

SUB Instructions2
  PRINT "Commands and speech strings can use capital or lowercase letters."
  PRINT
  PRINT "In PHONETIC ON mode"
  PRINT
  PRINT "Phonetic codes:"
  PRINT "  Vowel sounds: IY IH EH AE AA AH AO OH UH UX ER AX IX"
  PRINT "  Dipthongs:    EY AY OY AW OW UW"
  PRINT "  Consonants:   R L W WH Y M N NX B D G J Z ZH V DH"
  PRINT "                S SH F TH P T K CH /H"
  PRINT "  Other:        YX WX RX LX /X DX UL UM UN"
  PRINT
  PRINT "Stresses:"
  PRINT "1 2 3 4 5 6 7 8"
  PRINT
  PRINT "An example is:"
  PRINT "  WEH4LKUM TUW MAE4KSIHMAY7T"
  PRINT "This will say: Welcome to Maximite"
  PRINT
  PRINT "You can type it in lowercase, and it will do the same thing:"
  PRINT "  weh4lkum tuw mae4ksihmay7t"
  PRINT
END SUB

Instructions1

Intro$="Welcome to the Colour Maximite 2."
Prompt$="Please enter something for me to say, or Q to exit."

'PLAY TTS doesn't say "Maximite" correctly, so the program uses the phonetic version
IntroPhonetic$="Weh4lkum tuw thah kahlah mae4ksihmay7t tuw. Pliyz ehntah sahmthihnx fao miy tuw sey, ao kyuw tuw eh4ksiht."

'PLAY TTS Intro$ + " " + Prompt$
PLAY TTS PHONETIC IntroPhonetic$

PRINT Intro$
DO
        PRINT Prompt$
        INPUT Answer$

Test:   IF we.is_quit_key%(Answer$) THEN Exit Do

        UpAnswer$ = UCASE$(Answer$)
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
        ELSE IF LEFT$(UpAnswer$,5) = "*HELP" THEN
          PRINT
          Instructions1
          Instructions2
        ELSE IF LEFT$(UpAnswer$,7) = "*CONFIG" THEN
          IF PhoneticOn THEN
            PRINT "Phonetic ON"
          ELSE
            PRINT "Phonetic OFF"
          END IF
          PRINT "Pitch: ";Pitch
          PRINT "Speed: ";Speed
        ELSE
          IF PhoneticOn THEN
            ON ERROR SKIP
            PLAY TTS PHONETIC Answer$,Speed,Pitch
            IF MM.ERRNO THEN
              PRINT "I can't say that in PHONETIC ON mode. Error message:"
              PRINT MM.ERRMSG$
              PRINT "Please try something else or use *phonetic off"
            END IF
          ELSE
            ON ERROR SKIP
            PLAY TTS Answer$,Speed,Pitch
            IF MM.ERRNO THEN
              PRINT "I can't say that. Error message:"
              PRINT MM.ERRMSG$
            END IF
          END IF
        END IF
LOOP

we.end_program()
