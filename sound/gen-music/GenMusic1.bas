' Generative Music 1 for CMM2
' Based on the Molecular Music Box by Dr. Duncan Lockerby
' Rev 1.0.2 William M Leue 9/27/2020
' The composition is called "Composition #1 (Passacaglia in 32 Bits)", and is based
' on a simple 4E3 iteration in 4 voices.
'   Rev 1.0.0 -- original
'   Rev 1.0.1 -- fixed graphic bug, split voices into L and R speakers
'   Rev 1.0.2 -- Changed from square to triangular waveforms to lessen intermodulation distortion
'                Also fixed a few more graphic warts.

option default integer
option base 1

#Include "../../common/welcome.inc"

' beats per measure = 16, whole note is 4 beats
const BPM   = 16
const WHOLE = 4

' This is a sort of passacaglia on 4 rising notes
' On top of the bass obligato are 3 treble voices that also
' sing a rising motif that is a little higher in pitch than
' the bass. Note length variations are triggered by note coincidences,
' giving rise to a continuously shifting melange of harmony and
' dissidence. The pattern is completely deterministic but the repetition
' length is very long due to several relatively prime components.
const NSTART = E2
const NBASE  = 4

' music timing constants
const TLENGTH = 8192
const TSEG = 16
const SLENGTH = TLENGTH/TSEG
const NCNOTES = 72
const NDNOTES = 42

' pitch values
const LOW_BASS = 10
const HIGH_BASS = 13
const LOW_MOTIF = 14
const HIGH_MOTIF = 24
const SHORT_MOTIF = 3
const LONG_MOTIF = 4

' graphical constants
const STAFFX =  70
const STAFFY = 300
const STAFFV = 100
const STAFFM = 4
const STMLEN = 144
const STMINC = 16
const STAFFI = 30
const STAFFH = 4*STMLEN+STAFFI
const STSQLN = STMLEN\STMINC
const STPINC = STAFFV/8.0

const NOTRAD = 4
const NOTSTL = 24
const NOTFGL = 8

' global variables
dim VCOLORS(4) = (RGB(BLUE), RGB(GREEN), RGB(YELLOW), RGB(RED))

dim float CNotes(NCNOTES)
dim float DNotes(NDNOTES)
dim measure = 0
dim mmode = 1
dim num_measures = -1
dim n = 0
dim ctime = 0

' Main program
InitGraphics
ReadNotes
DrawStaff
we.clear_keyboard_buffer()
PlayGenMusic
we.end_program()

' set up mode 1 graphics
sub InitGraphics
  mode 1,8
  cls
end sub

' read notes for both Chromatic and Diatonic Scales
' (the chromatic scale is not used in this composition)
sub ReadNotes
  local i
  for i = 1 to NCNOTES
    read CNotes(i)
  next i
  for i = 1 to NDNOTES
    read DNotes(i)
  next i
end sub

' Generate music using the simplest possible scheme
sub PlayGenMusic
  local m, i
  local len1, freq1
  local len2, freq2, xlen2, mxfreq2
  local len3, freq3, xlen3, mxfreq3
  local len4, freq4, xlen4, mxfreq4

  len1 = 0
  mxfreq1 = HIGH_BASS
  mxfreq2 = HIGH_MOTIF
  mxfreq3 = HIGH_MOTIF+2
  mxfreq4 = HIGH_MOTIF+3

  freq1 = LOW_BASS
  freq2 = LOW_MOTIF
  freq3 = LOW_MOTIF+2
  freq4 = LOW_MOTIF+4

  len2 = 16
  xlen2 = LONG_MOTIF

  len3 = 32
  xlen3 = LONG_MOTIF

  len4 = 128
  xlen4 = LONG_MOTIF

  n = 1
  ctime = 0

  ' music loop runs forever.
  ' The measures eventually repeat exactly but it takes
  ' quite a few measures because of relatively prime durations
  ' measures are divided into 16 divisions. In 4 of them a
  ' new bass note begins. Treble notes can pay in any of the
  ' 16 divisions.
  do
    for m = 1 to 4
      measure = measure + 1
      if measure >= 5 then
        ScrollStaff measure
      endif
      for i = 1 to TSEG
        select case i
          ' these are the times where the base notes play
          case 1, 5, 9, 13
            if len1 = 0 then
              len1 = 4
              play sound 1,L,T,DNotes(freq1)
              DrawNote 1, measure, i, freq1, len1
              freq1 = freq1+1
              if freq1  > HIGH_BASS then freq1 = LOW_BASS
              len1 = len1-1
            end if
            if len2 = 0 then
              if xlen2 = LONG_MOTIF then xlen2 = SHORT_MOTIF else xlen2 = LONG_MOTIF
              play sound 2,L,T, DNotes(freq2)
              DrawNote 2, measure, i, freq2, xlen2
              freq2 = freq2+1
              if freq2 > mxfreq2 then freq2 = LOW_MOTIF
            end if
            if len3 = 0 then
              if xlen3 = LONG_MOTIF then xlen3 = SHORT_MOTIF else xlen3 = LONG_MOTIF
              play sound 3,R,T, DNotes(freq3)
              DrawNote 3, measure, i, freq3, xlen3
              freq3 = freq3+1
              if freq3 > mxfreq3 then freq3 = LOW_MOTIF+2
              len3 = xlen3-1
            end if
            if len4 = 0 then
              if xlen4 = LONG_MOTIF then xlen4 = SHORT_MOTIF else xlen4 = LONG_MOTIF
              play sound 4,R,T, DNotes(freq4)
              DrawNote 4, measure, i, freq4, xlen4
              freq4 = freq4+1
              if freq4 > mxfreq4 then freq4 = LOW_MOTIF+4
              len4 = xlen4-1
            end if
            pause SLENGTH
            ctime = ctime + CTSTEP
          ' only treble notes play in these times
          case 2 to 4, 6 to 8, 10 to 12, 14 to 16
            len1 = len1-1
            len2 = len2-1
            len3 = len3-1
            len4 = len4-1
            if len2 = 0 then
              if xlen2 = LONG_MOTIF then xlen2 = SHORT_MOTIF else xlen2 = LONG_MOTIF
              play sound 2,L,T, DNotes(freq2)
              DrawNote 2, measure, i, freq2, xlen2
              freq2 = freq2+1
              if freq2 > mxfreq2 then freq2 = LOW_MOTIF
              len2 = xlen2-1
            end if
            if len3 = 0 then
              if xlen3 = LONG_MOTIF then xlen3 = SHORT_MOTIF else xlen3 = LONG_MOTIF
              play sound 3,R,T, DNotes(freq3)
              DrawNote 3, measure, i, freq3, xlen3
              freq3 = freq3+1
              if freq3 > mxfreq3 then freq3 = LOW_MOTIF+2
              len3 = xlen3-1
            end if
            if len4 = 0 then
              if xlen4 = LONG_MOTIF then xlen4 = SHORT_MOTIF else xlen4 = LONG_MOTIF
              play sound 4,R,T, DNotes(freq4)
              DrawNote 4, measure, i, freq4, xlen4
              freq4 = freq4+1
              if freq4 > mxfreq4 then freq4 = LOW_MOTIF+4
              len4 = xlen4-1
            end if
            ctime = ctime + CTSTEP
            pause SLENGTH
        end select
        If we.is_quit_pressed%() Then Exit Sub
      next i
    next m
  loop
end sub


' Draw the 5-line treble staff (I didn't bother with the treble sign)
sub DrawStaff
  local x1, y1, x2, y2, i, m

  text 400, 30, "Composition #1 (Passacaglia in 32 bits)", "CB"
  text 400, 45, "by Bill Leue", "CB"
  text 400, 580, "Press Q to Quit", "CB"
  box STAFFX, STAFFY, STAFFH, STAFFV
  for i = 1 to 3
    x1 = STAFFX
    y1 = STAFFY + i*(STAFFV/4)
    x2 = STAFFX + STAFFH - 1
    y2 = y1
    line x1, y1, x2, y2
  next i
  text STAFFX+5, STAFFY+STAFFV+15, "1"
  text STAFFX+5, STAFFY+STAFFV+30, "Largo"
  for i = 2 to STAFFM
    x1 = STAFFX+STAFFI + (i-1)*STMLEN
    y1 = STAFFY
    x2 = x1
    y2 = STAFFY+STAFFV-1
    line x1, y1, x2, y2
    text x1+5, STAFFY+STAFFV+15, str$(i)
  next i
  'DrawClef
  'DrawTSig
end sub

' As the piece progresses, the staff scrolls right to left, bringing in new measures
sub ScrollStaff measure
  local x1, y1, x2, y2, i, m

  page scroll 0, -STMLEN, 0, RGB(BLACK)
  x1 = STAFFX+STAFFH-STMLEN
  x2 = x1 + STMLEN
  line x2, STAFFY, x2, STAFFY+STAFFV
  for i = 1 to 5
    y1 = STAFFY + (i-1)*(STAFFV/4)
    y2 = y1
    line x1, y1, x2, y2
  next i
  text x1+5, STAFFY+STAFFV+15, str$(measure)
end sub

' Not currently used
sub DrawClef
  load PNG "TrebleClef.png", STAFFX+2, STAFFY+22, 15
end sub

' Not currently used
sub DrawTSig
end sub

' Draw a note. Only quarter notes and dotted eighth notes appear
' To make it more readable, the 3rd voice notes are turned upside down.
sub DrawNote voice, measure, seq, pitch, duration
  local x, y, xc, xs, fc, m
  local xv(4), yv(4)

  m = measure
  if m > 4 then m = 4

  x = STAFFX+STAFFI+(m-1)*STMLEN+(seq-1)*STSQLN+4
  y = STAFFY+STAFFV-1-(pitch-10)*STPINC
  xc = x+NOTRAD
  if pitch > 18 and pitch mod 2 = 0 then
    line x-6, y, x+14, y,, RGB(WHITE)
  end if
  circle xc, y, NOTRAD, 1, 1.50, VCOLORS(voice), VCOLORS(voice)
  xs = x + 2*NOTRAD
  if voice = 1 or voice = 2 or voice = 4 then
    line xs, y, xs, y-NOTSTL, 2, VCOLORS(voice)
  else
    line xs, y, xs, y+NOTSTL, 2, VCOLORS(voice)
  end if
  fc = 0
  if duration = 3 then fc = 1
  for i = 1 to fc
    xv(1) = xs
    xv(2) = xv(1)-NOTFGL
    xv(3) = xv(1)
    if voice = 1 or voice = 2 or voice = 4 then
      yv(1) = y-NOTSTL+(i-1)*7
      yv(2) = yv(1) + 3
      yv(3) = yv(1) + 5
    else
      yv(1) = y+NOTSTL-(i-1)*7
      yv(2) = yv(1) - 3
      yv(3) = yv(1) - 5
    end if
    xv(4) = xv(1) : yv(4) = yv(1)
  polygon 4, xv(), yv(), VCOLORS(voice), VCOLORS(voice)
  next i
  if duration = 3 then
    circle xc+NOTRAD+9, y, 2, 1, 1, VCOLORS(voice), VCOLORS(voice)
  end if
end sub

' The lowest and highest octaves on a standard 88-key piano are omitted because
' My cheapo speakers cannot reproduce the sounds well.

' frequencies for tempered chromatic scale (6 octaves)
data 65.406, 69.296, 73.416, 77.782, 82.407, 87.307, 92.499, 97.999, 103.83, 110.0, 116.54, 123.47
data 130.81, 138.59, 146.83, 155.56, 164.81, 174.61, 185.0, 196.0, 207.65, 220.0, 233.08, 246.94
data 261.63, 277.18, 293.66, 311.13, 329.63, 349.23, 369.99, 392.0, 415.30, 440.0, 466.16, 493.88
data 523.25, 554.37, 587.33, 622.25, 659.25, 698.46, 739.99, 783.99, 830.61, 880.0, 932.33, 987.77
data 1046.5, 1108.7, 1174.7, 1244.5, 1318.5, 1369.9, 1480.0, 1568.0, 1661.2, 1760.0, 1864.7, 1979.5
data 2093.0, 2217.5, 2349.3, 2489.0, 2637.0, 2793.8, 2960.0, 3136.0, 3322.4, 3520.0, 3729.3, 3951.1

' frequencies for tempered diatonic scale (6 octaves)
data 65.406, 73.416, 82.407, 87.307, 97.999, 110.0, 123.47
data 130.81, 146.83, 164.81, 174.61, 196.0, 220.0, 246.94
data 261.63, 293.66, 329.63, 349.23, 392.0, 440.0, 493.88
data 523.25, 587.33, 659.25, 698.46, 783.99, 880.0, 987.77
data 1046.5, 1174.7, 1318.5, 1369.9, 1568.0, 1760.0, 1979.5
data 2093.0, 2349.3, 2637.0, 2793.8, 3136.0, 3520.0, 3951.1
