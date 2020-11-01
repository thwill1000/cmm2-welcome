' Mr. Polysynth v1.1
' Code by "TweakerRay"
' Messed about with for the CMM2 Welcome Tape by "thwill"

Option Explicit On
Option Base 1

#Include "../../common/welcome.inc"

cls
const MY_GREEN = rgb(40,255,20)

color rgb(white)
?" Welcome to Polysynth v1.1"
?
?" You can only play the synth with a ";
color rgb(yellow)
? "USB ";
color rgb(white)
? "keyboard; ";
color rgb(yellow)
? "a serial connection is not sufficient."
?
color rgb(white)
?" Use the keys from Q-P as White Keys and the number keys above as Black keys of a Piano."
?
color MY_GREEN
?"  2  3        5  6  7     9  0     <----- Black Keys"
?
?" Q  W  E  R  T  Z  U  I  O  P      <----- White Keys"
?
color rgb(white)
?" The synth can play up to 4 notes simultaneously with sound coming from both speakers."
?
color rgb(yellow)
?" Note that not all keyboards support 4 simultaneous keypresses for all key combinations."
?
color rgb(white)
?" You can change the Octaves on the 4 notes independently:"
?
color MY_GREEN
?" F1 / F2        -  Octave up / down on Note 1"
?" F3 / F4        -  Octave up / down on Note 2"
?" F5 / F6        -  Octave up / down on Note 3"
?" F7 / F8        -  Octave up / down on Note 4"
?" F9 / F10       -  Octave up / down on ALL 4 Notes"
?" F11            -  Reset All octaves to Zero"
?" F12            -  Reset Tuning to Zero"
?
color rgb(white)
?" Change the Sound on the Channels:"
?
color MY_GREEN
?" A / S / D / F  -  Sound change + on Channel 1 / 2 / 3 / 4 (Square or Sine)"
?" Y / X / C / V  -  Sound change - on Channel 1 / 2 / 3 / 4 (Square or Sine)"
?
color rgb(white)
?" Detune the Channels:"
?
color MY_GREEN
?" G / H / J / K  -  Detune + on Note 1 / 2 / 3 / 4"
?" B / N / M / ,  -  Detune - on Note 1 / 2 / 3 / 4"
?
color rgb(white)
?" Press [Esc] to Quit"

do while inkey$<>"" : loop
do while inkey$="" : loop

cls

dim freq(88)
dim layout$ = mm.info$(option usbkeyboard)
dim okt(4)
dim s(4) ' 1=square, 2=sine, 3=noise
dim tnr(4) = (-1,-1,-1,-1)
dim tnr_new(4) = (-1,-1,-1,-1)
dim tune(4)
dim volume=12 ' Volume 1-25

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

main()
end ' Should never get here.

sub main()
  local i

  do
    for i = 1 to 4 : handle_keypress(i) : next
    apply_restrictions()
    update_notes()
    update_display()
    play_notes()
  loop
end sub

sub handle_keypress(i)
  local j, key$

  key$=chr$(keydown(i))

  if key$=chr$(27) then we.end_program()

  ' Check for keys corresponding to musical notes
  for j=28 to 44
    if key$=ta$(j) then tnr_new(i)=j : Exit Sub
  next
  tnr_new(i) = -1 ' no note on this key

  select case key$

    ' Channel Oktave up and down
    case chr$(145) : okt(1)=okt(1)-12 ' F1
    case chr$(146) : okt(1)=okt(1)+12 ' F2
    case chr$(147) : okt(2)=okt(2)-12 ' F3
    case chr$(148) : okt(2)=okt(2)+12 ' F4
    case chr$(149) : okt(3)=okt(3)-12 ' F5
    case chr$(150) : okt(3)=okt(3)+12 ' F6
    case chr$(151) : okt(4)=okt(4)-12 ' F7
    case chr$(152) : okt(4)=okt(4)+12 ' F8

    ' All four Channels Oktave up and down
    case chr$(153) : for j=1 to 4 : okt(j)=okt(j)-12 : next ' F9
    case chr$(154) : for j=1 to 4 : okt(j)=okt(j)+12 : next ' F10

    ' Reset Tuning + Reset Oktaves
    case chr$(155) : for j=1 to 4 : okt(j)=0 : next ' F11
    case chr$(156) : for j=1 to 4 : tune(j)=0 : next ' F12

    ' Sound changes 1-4
    case "a"      : s(1)=s(1)+1
    ' If "y" or "z" corresponds to a musical note key then this sub will already have exited.
    case "y", "z" : s(1)=s(1)-1
    case "s"      : s(2)=s(2)+1
    case "x"      : s(2)=s(2)-1
    case "d"      : s(3)=s(3)+1
    case "c"      : s(3)=s(3)-1
    case "f"      : s(4)=s(4)+1
    case "v"      : s(4)=s(4)-1

    ' Detune channels 1-4
    case "g" : tune(1)=tune(1)+0.1
    case "b" : tune(1)=tune(1)-0.1
    case "h" : tune(2)=tune(2)+0.1
    case "n" : tune(2)=tune(2)-0.1
    case "j" : tune(3)=tune(3)+0.1
    case "m" : tune(3)=tune(3)-0.1
    case "k" : tune(4)=tune(4)+0.1
    case "," : tune(4)=tune(4)-0.1

    case else : exit sub

  end select

  pause 100
end sub

sub apply_restrictions()
  local i

  ' Restrict ocatave values to range -24 .. +48.
  for i = 1 to 4
    okt(i) = min(okt(i), 48)
    okt(i) = max(okt(i), -24)
  next

  ' Restrict sound values.
  ' Only sounds 1 & 2 are useful, 3 and 4 are noise.
  for i = 1 to 4
    if s(i) <= 1 then s(i)=1 else s(i)=2
  next

  ' Restrict frequency.
  for i = 1 to 4
    if okt(i)=48 then tnr_new(i) = min(tnr_new(i), 40)
  next
end sub

sub update_notes()
  local i, j

  ' Remove notes from tnr() that are not in tnr_new()
  for i=1 to 4
    if tnr(i) > -1 then
      for j=1 to 4
        if tnr_new(j)=tnr(i) then tnr_new(j)=-1 : exit for
      next j
      if j=5 then tnr(i)=-1
    endif
  next i

  ' Add new notes from tnr_new() to tnr()
  for i=1 to 4
    if tnr_new(i) > -1 then
      for j=1 to 4
        if tnr(j)=-1 then tnr(j)=tnr_new(i) : exit for
      next j
      if j=5 then error "Should not happen"
    endif
  next i
end sub

sub update_display()
  local i

  font 2

  color rgb(rnd()*255,rnd()*255,rnd()*255)
  print @(12,1) "* * * * * * * * * Mr. Polysynth by TweakerRay * * * * * * * * *"
  color rgb(0,255,0)

  print @(10,100) "Num keys  :" format$(keydown(0), "%4g")

  print @(10,120) "Frequency :";
  for i = 1 To 4
    if tnr(i) = -1 then
      print " -------";
    else
      print format$(freq(tnr(i)), "%8g");
    endif
  next
  print

  print @(10,160) "Tuning    :";
  for i = 1 to 4 : print format$(tune(i), "%4g"); : next : print

  print @(10,180) "Octave    :";
  for i = 1 to 4 : print format$(okt(i), "%4g"); : next : print

  print @(10,200) "Key num   :";
  for i = 1 to 4
    if tnr(i) = -1 then
      print "   -";
    else
      print format$(tnr(i)+okt(i), "%4g");
    endif
  next
  print

  print @(10,220) "Sound     :";
  for i = 1 To 4 : print format$(s(i), "%4g"); : next : print

  print @(10,240) "Layout    :  ";layout$

  font 1
  print @(10,320) "More music at http://tweakerray.bandcamp,com"
  print @(10,340) "And follow at http://www.youtube.com/tweakerray"
end sub

sub play_notes()
  local f, i

  for i=1 to 4
    if tnr(i) > -1 then
      f = freq(tnr(i) + okt(i)) + tune(i)
      select case s(i)
        case 1 : play sound i,B,Q,f,volume
        case 2 : play sound i,B,S,f,volume
      end select
    else
      play sound i,B,O
    endif
  next
end sub
