' Mr. Polysynth
' Code by "TweakerRay"
' Messed about with for the CMM2 Welcome Tape by "thwill"

Option Explicit On
Option Base 1

#Include "../../common/welcome.inc"

cls
color rgb(40,255,20)

?" Hi ! This is my small Polysynth V1"
?" "
?" You can play the synth with your keyboard:"
?" Just imagine the Keys from Q-P as White Keys and the numberkeys above as Black keys of a Piano"
?" "
?"  2  3        5  6  7     9  0     <----- Black Keys"
?" "
?" Q  W  E  R  T  Z  U  I  O  P      <----- White Keys"
?" "
?" The Synth can play up to 4 Notes simultaneously. All sounds come from both Speakers."
?" "
?" You can change the okaves on the 4 Notes independently:"
?" "
?" F1 / F2  Oktave up / down on Note 1"
?" F3 / F4  Oktave up / down on Note 2"
?" F5 / F6  Oktave up / down on Note 3"
?" F7 / F8  Oktave up / down on Note 4"
?" F9 / F10 Oktave up / down on ALL 4 Notes"
?" F11  Reset All oktaves to Zero   "
?" F12  Reset Tuning to Zero     "
?" "
?" Change the Sound on the Channel:"
?" "
?" A / S / D / F  -  Sound change + on Channel 1 / 2 / 3 / 4 (Square or Sine)"
?" Y / X / C / V  -  Sound change - on Channel 1 / 2 / 3 / 4 (Square or Sine)"
?" "
?" Detune Channels with:"
?" "
?" G / H / J / K  -  Detune + on Note 1 / 2 / 3 / 4"
?" B / N / M / ,  -  Detune - on Note 1 / 2 / 3 / 4"
?" "
?" "
?" Press [Esc] to Quit"

do while inkey$<>"" : loop
do while inkey$="" : loop

cls

dim i,j
dim k1,k2,k3,k4,keys
dim x
dim layout$ = mm.info$(option usbkeyboard)
dim volume=12 ' Volume 1-25
dim fullkey1,fullkey2,fullkey3,fullkey4
dim okt1,okt2,okt3,okt4
dim s1,s2,s3,s4 ' 1=square, 2=sine, 3=noise
dim switch
dim tune1,tune2,tune3,tune4

dim tnr(4) = (28,28,28,28) ' For if okt would be pressed before a key we set the key to C2

dim freq(88)
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

dim ta$(88)
ta$(28)="q"
ta$(29)="2"
ta$(30)="w"
ta$(31)="3"
ta$(32)="e"
ta$(33)="r"
ta$(34)="5"
ta$(35)="t"
ta$(36)="6"
if layout$="DE" then ta$(37)="z" else ta$(37)="y"
ta$(38)="7"
ta$(39)="u"
ta$(40)="i"
ta$(41)="9"
ta$(42)="o"
ta$(43)="0"
ta$(44)="p"

do
  k1=keydown(1)
  k2=keydown(2)
  k3=keydown(3)
  k4=keydown(4)
  keys=keydown(0)

  font 2

Screenstart:

  ' For Checking the Keys coming in...
  '  Print @(10,40)"Taste:";k1;"   ";k2;"   ";k3;"   ";k4;"   ";keys;"  "
  '  Print @(10,80)"Buffer:";buffer$;"  "

  Print @(10,100) "Keydown:";keydown(0);" "
  Print @(10,120) "Frequency:"
  print @(130,120) "";freq(tnr(1))
  print @(250,120) "";freq(tnr(2))
  Print @(370,120) "";freq(tnr(3))
  Print @(490,120) "";freq(tnr(4))

  print @(10,240) "Sound:";s1;s2;s3;s4;"   "
  print @(10,160) "Tuning:";tune1;" ";tune2;" ";tune3;" ";tune4;"               "
  print @(10,180) "Oktave:";okt1;okt2;okt3;okt4;"              "
  print @(10,200) "keynr:";fullkey1;fullkey2;fullkey3;fullkey4;"         "
  print @(10,220) "Layout:";layout$

  font 1
  print @(10,320) "More music at http://tweakerray.bandcamp,com"
  print @(10,340) "And follow at http://www.youtube.com/tweakerray"

  font 2

  do
    color rgb(rnd()*255,rnd()*255,rnd()*255)
    ?@(12,1) "* * * * * * * * * Mr. Polysynth by TweakerRay * * * * * * * * *" :
    color rgb(0,255,0)
    if keydown(0) > 0 then exit do
    play stop
  loop

  for i=1 to keydown(0)

    handle_keypress(i)

    ' Restrict ocatave values.
    if okt1>48 then okt1=48
    if okt2>48 then okt2=48
    if okt3>48 then okt3=48
    if okt4>48 then okt4=48
    if okt1<-24 then okt1=-24
    if okt2<-24 then okt2=-24
    if okt3<-24 then okt3=-24
    if okt4<-24 then okt4=-24

    ' Restrict sound values.
    ' Only sounds 1 & 2 are useful, 3 and 4 are noise.
    if s1<=1 then s1=1 else s1=2
    if s2<=1 then s2=1 else s2=2
    if s3<=1 then s3=1 else s3=2
    if s4<=1 then s4=1 else s4=2

    ' Checking restrictions of frequency (Not below 20 Hz or over 20 Khz)

    ' Check if keyvalue too high or low
    fullkey1=tnr(1)+okt1
    fullkey2=tnr(2)+okt2
    fullkey3=tnr(3)+okt3
    fullkey4=tnr(4)+okt4

    if okt1=48 and tnr(1)>40 then tnr(1)=40
    if okt2=48 and tnr(2)>40 then tnr(2)=40
    if okt3=48 and tnr(3)>40 then tnr(3)=40
    if okt4=48 and tnr(4)>40 then tnr(4)=40

    ' Check if the same key is pressed, which means the sound is already playing
    ' if buffer$=tpress$ then samesound=1 else samesound=0
    ' buffer$=tpress$

  next i

  if switch=0 goto Screenstart

  play_notes()

loop

sub handle_keypress(i)
  Local k$

  k$=chr$(keydown(i))

  if k$=chr$(27) then we.end_program()

  ' Check for keys corresponding to musical notes
  switch = 0
  for j=28 to 44
    if k$=ta$(j) then tnr(i)=j : switch = 1 : Exit Sub
  next j

  Select Case k$

    ' Channel Oktave up and down
    Case chr$(145) : okt1=okt1-12 ' F1
    Case chr$(146) : okt1=okt1+12 ' F2
    Case chr$(147) : okt2=okt2-12 ' F3
    Case chr$(148) : okt2=okt2+12 ' F4
    Case chr$(149) : okt3=okt3-12 ' F5
    Case chr$(150) : okt3=okt3+12 ' F6
    Case chr$(151) : okt4=okt4-12 ' F7
    Case chr$(152) : okt4=okt4+12 ' F8

    ' All four Channels Oktave up and down
    Case chr$(153) : okt1=okt1-12 : okt2=okt2-12 : okt3=okt3-12 : okt4=okt4-12 ' F9
    Case chr$(154) : okt1=okt1+12 : okt2=okt2+12 : okt3=okt3+12 : okt4=okt4+12 ' F10

    ' Reset Tuning + Reset Oktaves
    Case chr$(155) : okt1=0 : okt2=0 : okt3=0 : okt4=0 ' F11
    Case chr$(156) : tune1=0 : tune2=0 : tune3=0 : tune4=0 ' F12

    ' Sound changes 1-4
    Case "a"      : s1=s1+1
     ' If "y" or "z" corresponds to a musical note key then this sub will already have exited.
    Case "y", "z" : s1=s1-1
    Case "s"      : s2=s2+1
    Case "x"      : s2=s2-1
    Case "d"      : s3=s3+1
    Case "c"      : s3=s3-1
    Case "f"      : s4=s4+1
    Case "v"      : s4=s4-1

    ' Detune channels 1-4
    Case "g" : tune1=tune1+0.1
    Case "b" : tune1=tune1-0.1
    Case "h" : tune2=tune2+0.1
    Case "n" : tune2=tune2-0.1
    Case "j" : tune3=tune3+0.1
    Case "m" : tune3=tune3-0.1
    Case "k" : tune4=tune4+0.1
    Case "," : tune4=tune4-0.1

    Case Else : Exit Sub

  End Select

  keys=keys-1
  pause 50
end sub

sub play_notes()
  if s1=1 and keys>0 then play sound 1,B,Q,freq(tnr(1)+okt1)+tune1,volume
  if s1=2 and keys>0 then play sound 1,B,S,freq(tnr(1)+okt1)+tune1,volume

  if s2=1 and keys>1 then play sound 2,B,Q,freq(tnr(2)+okt2)+tune2,volume
  if s2=2 and keys>1 then play sound 2,B,S,freq(tnr(2)+okt2)+tune2,volume

  if s3=1 and keys>2 then play sound 3,B,Q,freq(tnr(3)+okt3)+tune3,volume
  if s3=2 and keys>2 then play sound 3,B,S,freq(tnr(3)+okt3)+tune3,volume

  if s4=1 and keys>3 then play sound 4,B,Q,freq(tnr(4)+okt4)+tune4,volume
  if s4=2 and keys>3 then play sound 4,B,S,freq(tnr(4)+okt4)+tune4,volume
end sub
