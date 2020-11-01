' Scales v1.1
' Code by "TweakerRay"
' Messed about with for the CMM2 Welcome Tape by "thwill"

#Include "../../common/welcome.inc"

volume=12
tnr=28 ' Key set to C2 as start
switch=0
scn=1 ' 1=Major 2=Minor

dim freq(88),freq1(88),freq2(88),freq3(88),freq4(88),t$(88)
dim freqmaj(9),Freqmin(9)
dim scalen$(12),ts$(12,12) ' Scalenames + Tonesteps Roman Numbers
dim triad(12,7,3)
dim r(4) ' Random numbers

freq(01)=27.5000 : freq(11)=48.9995 : freq(21)=87.3071 : freq(31)=155.563
freq(02)=29.1353 : freq(12)=51.9130 : freq(22)=92.4986 : freq(32)=164.814
freq(03)=30.8677 : freq(13)=55.0000 : freq(23)=97.9989 : freq(33)=174.614
freq(04)=32.7032 : freq(14)=58.2705 : freq(24)=103.826 : freq(34)=184.997
freq(05)=34.6479 : freq(15)=61.7354 : freq(25)=110.000 : freq(35)=195.998
freq(06)=36.7081 : freq(16)=65.4064 : freq(26)=116.541 : freq(36)=207.652
freq(07)=38.8909 : freq(17)=69.2957 : freq(27)=123.471 : freq(37)=220.000
freq(08)=41.2035 : freq(18)=73.4162 : freq(28)=130.813 : freq(38)=233.082
freq(09)=43.6536 : freq(19)=77.7817 : freq(29)=138.591 : freq(39)=246.942
freq(10)=46.2493 : freq(20)=82.4069 : freq(30)=146.832 : freq(40)=261.626

freq(41)=277.183 : freq(51)=493.883 : freq(61)=880.000 : freq(71)=1567.98
freq(42)=293.665 : freq(52)=523.251 : freq(62)=932.328 : freq(72)=1661.22
freq(43)=311.127 : freq(53)=554.365 : freq(63)=987.767 : freq(73)=1760.00
freq(44)=329.628 : freq(54)=587.330 : freq(64)=1046.50 : freq(74)=1864.66
freq(45)=349.228 : freq(55)=622.254 : freq(65)=1108.73 : freq(75)=1975.53
freq(46)=369.994 : freq(56)=659.255 : freq(66)=1174.66 : freq(76)=2093.00
freq(47)=391.995 : freq(57)=698.456 : freq(67)=1244.51 : freq(77)=2217.46
freq(48)=415.305 : freq(58)=739.989 : freq(68)=1318.51 : freq(78)=2349.32
freq(49)=440.000 : freq(59)=783.991 : freq(69)=1396.91 : freq(79)=2489.02
freq(50)=466.164 : freq(60)=830.609 : freq(70)=1479.98 : freq(80)=2637.02

freq(81)=2793.83
freq(82)=2959.96
freq(83)=3135.96
freq(84)=3322.44
freq(85)=3520.00
freq(86)=3729.31
freq(87)=3951.07
freq(88)=4186.01

'Define Major Scale
Freqmaj(1)=0
Freqmaj(2)=2
Freqmaj(3)=4
Freqmaj(4)=5
Freqmaj(5)=7
Freqmaj(6)=9
Freqmaj(7)=11
Freqmaj(8)=12
freqmaj(9)=0

'Define Minor Scale
Freqmin(1)=0
Freqmin(2)=2
Freqmin(3)=3
Freqmin(4)=5
Freqmin(5)=7
Freqmin(6)=8
Freqmin(7)=10
Freqmin(8)=12
freqmin(9)=0

'Define Scalename
Scalen$(1)="Major"
Scalen$(2)="minor"

'Triad Steps in Roman Numbers for Major Scale
ts$(1,1)="I   (Major) - Tonic      "
ts$(1,2)="ii  (minor)              "
ts$(1,3)="iii (minor)              "
ts$(1,4)="IV  (Major) - Subdominant"
ts$(1,5)="V   (Major) - Dominant   "
ts$(1,6)="vi  (minor) - T-Parallel "
ts$(1,7)="vii (diminished)         "

ts$(2,1)="i   (minor) - Tonic      "
ts$(2,2)="ii  (diminished)         "
ts$(2,3)="III (Major) - T-Parallel "
ts$(2,4)="iv  (minor)              "
ts$(2,5)="v   (minor)              "
ts$(2,6)="VI  (Major) - Subdominant"
ts$(2,7)="VII (Major) - Dominant   "

' Major Triads

triad(1,1,1)=0
triad(1,1,2)=4
triad(1,1,3)=7

triad(1,2,1)=2
triad(1,2,2)=5
triad(1,2,3)=9

triad(1,3,1)=4
triad(1,3,2)=7
triad(1,3,3)=11

triad(1,4,1)=5
triad(1,4,2)=9
triad(1,4,3)=12

triad(1,5,1)=7
triad(1,5,2)=11
triad(1,5,3)=14

triad(1,6,1)=9
triad(1,6,2)=12
triad(1,6,3)=16

triad(1,7,1)=11
triad(1,7,2)=14
triad(1,7,3)=17

' minor Triads
triad(2,1,1)=0
triad(2,1,2)=3
triad(2,1,3)=7

triad(2,2,1)=2
triad(2,2,2)=5
triad(2,2,3)=8

triad(2,3,1)=3
triad(2,3,2)=7
triad(2,3,3)=10

triad(2,4,1)=5
triad(2,4,2)=8
triad(2,4,3)=12

triad(2,5,1)=7
triad(2,5,2)=10
triad(2,5,3)=14

triad(2,6,1)=8
triad(2,6,2)=12
triad(2,6,3)=15

triad(2,7,1)=10
triad(2,7,2)=14
triad(2,7,3)=17

' Fill frequency table for all 4 channels
for x=1 to 88
  freq1(x)=freq(x) : freq2(x)=freq(x) : freq3(x)=freq(x) : freq4(x)=freq(x)
next x

t$(25)="A "
t$(26)="A#"
t$(27)="H "
t$(28)="C "
t$(29)="C#"
t$(30)="D "
t$(31)="D#"
t$(32)="E "
t$(33)="F "
t$(34)="F#"
t$(35)="G "
t$(36)="G#"
t$(37)="A "
t$(38)="A#"
t$(39)="H "
t$(40)="C "
t$(41)="C#"
t$(42)="D "
t$(43)="D#"
t$(44)="E "
t$(45)="F "
t$(46)="F#"
t$(47)="G "
t$(48)="G#"
t$(49)="A "
t$(50)="A#"
t$(51)="H "
t$(52)="C "

' Set sounds to same on all 4 channels
freq1(tnr)=freq(28)
freq2(tnr)=freq(28)
freq3(tnr)=freq(28)
freq4(tnr)=freq(28)

helptext
printscreen

do
  taste$=inkey$

  select case taste$
    case " "
      checkscale()
    case chr$(145) ' F1
      tnr=tnr-1
    case chr$(146) ' F2
      tnr=tnr+1
    case "p", "P"
      parallele()
    case "a", "A"
      switcha = not switcha
    case "1", "2", "3", "4", "5", "6", "7"
      trn = val(taste$)
      arpselect
    case "c", "C"
      randomize4(1)
    case "r", "R"
      randomize4
    case "h", "H"
      helptext(1)
    case "q", "Q" ' Quit
      exit do      
  end select

  ' Apply restrictions.
  if scn<1 then scn=1
  if scn>2 then scn=2
  if scn=1 and tnr<28 then tnr=28
  if scn=2 and tnr<25 then tnr=25
  if scn=1 and tnr>39 then tnr=39
  if scn=2 and tnr>36 then tnr=36

  if taste$<> "" then printscreen

loop

we.end_program()

sub arpselect
  if switcha then triadplayarpmode else triadplay
end sub

' Scale Select
sub checkscale
  if scn=1 then Playscalemaj
  if scn=2 then Playscalemin
end sub

' Scale Maj
sub Playscalemaj
  color rgb(255,255,40)
  ?@(1,60)
  for x=1 to 8
    play sound 1,B,Q,Freq(tnr+freqmaj(x)),volume
    pause 200
    ?t$(tnr+freqmaj(x));"  ";ts$(1,x)
    if freqmaj(x+1)-freqmaj(x)=2 then color rgb(255,255,40) : ?x;" Full Step"
    if freqmaj(x+1)-freqmaj(x)=1 then color rgb(255,0,0) : ?x;" Half Step" : color rgb(255,255,40)
  next x
  play stop
end sub

' Scale Min
sub Playscalemin
  color rgb(255,255,40)
  ?@(1,60)
  for x=1 to 8
    play sound 1,B,Q,Freq(tnr+freqmin(x)),volume
    pause 200
    ?t$(tnr+freqmin(x));"  ";ts$(2,x)
    if freqmin(x+1)-freqmin(x)=2 then color rgb(255,255,40) : ?x;" Full Step"
    if freqmin(x+1)-freqmin(x)=1 then color rgb(255,0,0) : ?x;" Half Step" : color rgb(255,255,40)
  next x
  play stop
end sub

sub printscreen
  color rgb(255,255,40)
  ?@(001,10) "Scale: ";T$(tnr)
  ' ?@(120,10)"";chr$(asc(taste$)) - just for debuggin which key is pressed
  ' ?@(240,10)"";tnr - Just for debugging - tnr is the number of the note selected
  ?@(320,10) "Mode: ";scalen$(scn)
end sub

sub triadplayarpmode
  for x=1 to 10
    play sound 1,B,Q,Freq(tnr+triad(scn,trn,1)),volume
    pause 20
    play sound 1,B,Q,Freq(tnr+triad(scn,trn,2)),volume
    pause 20
    play sound 1,B,Q,Freq(tnr+triad(scn,trn,3)),volume
    pause 20
  next x
  play stop
end sub

sub triadplay
  play sound 1,B,Q,Freq(tnr+triad(scn,trn,1)),volume
  play sound 2,B,Q,Freq(tnr+triad(scn,trn,2)),volume
  play sound 3,B,Q,Freq(tnr+triad(scn,trn,3)),volume
  pause 400
  play stop
end sub

' Change to parallel Mode Major or minor scale
sub parallele
  if switch then
    scn=1
    switch=0
    tnr=tnr+3
  elseif tnr>=28 then
    scn=2
    switch=1
    tnr=tnr-3
  endif
end sub

sub randomize4(replay)

  if not replay then
    do
      r(1)=int(rnd(1)*7)+1
      r(2)=int(rnd(1)*7)+1
      r(3)=int(rnd(1)*7)+1
      r(4)=int(rnd(1)*7)+1
    loop until r(1) <> 0
  endif

  if switcha then

    for x=1 to 4
      ?@(1,400+x*20);ts$(scn,r(x));r(x)
      for y=1 to 10
        play sound 1,B,Q,Freq(tnr+triad(scn,r(x),1)),volume
        pause 20
        play sound 1,B,Q,Freq(tnr+triad(scn,r(x),2)),volume
        pause 20
        play sound 1,B,Q,Freq(tnr+triad(scn,r(x),3)),volume
        pause 20
        play stop
      next y
    next x

  else

    for x=1 to 4
      ?@(1,400+x*20);ts$(scn,r(x));r(x)
      play sound 1,B,Q,Freq(tnr+triad(scn,r(x),1)),volume
      play sound 2,B,Q,Freq(tnr+triad(scn,r(x),2)),volume
      play sound 3,B,Q,Freq(tnr+triad(scn,r(x),3)),volume
      pause 600
      play stop
    next x

  endif

end sub

sub helptext(banner)
  color rgb(255,255,40)
  cls
  font 1

  ? " "
  if banner then
    ?"Helpscreen:"
    ?" "
  endif
  ?"Scales V1 - A little Harmony Educating Help Program."
  ?" "
  ?" "
  ?"(by TweakerRay - www.tweakerray.de)"
  ?" "
  ?" "
  ?"This Program shows you where half steps and full steps of a scale are."
  ?"You can listen to the scale and also can listen to their Harmony chords."
  ?" "
  ?"F1 / F2 Change Starting point of the scale"
  ?" "
  ?"Space - Play Scale"
  ?" "
  ?"1-7 Play the corresponding Harmony-Chord of that scale (I - VII)"
  ?" "
  ?"P - Toggle to Parallel Major or Minorscale (For Example C-Maj to A-min)"
  ?" "
  ?"R - Randomize 4 chords corresponding to your selected scale"
  ?" "
  ?"C - Play the randomized chords again..."
  ?" "
  ?"A - Arpmode on / off - (Just to change the sound if you like oldschool arps ;-) )"
  ?
  ?"Q - Quit"
  ?
  ?
  ?"Press any key to continue."

  do while inkey$ <> "" : loop
  do while inkey$ = "" : loop

  cls
  font 2
end sub
