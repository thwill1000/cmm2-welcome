' Scrolling Fading Text Demo
' Author: vegipete
'         CSUB by "jirsoft"
'         original CSUB by The Sasquatch
' From:   https://www.thebackshed.com/forum/ViewTopic.php?TID=12876

#Include "../../common/welcome.inc"

we.check_firmware_version("5.06.00")

Mode 1,8

page write 2 : cls
page write 1 : cls : text 0, 0, "Press Q to Quit"
page write 0 : cls

dim integer sw_x = 125      ' scroll window x location
dim integer sw_y = 100      ' y location
dim integer sw_width = 550  ' width
dim integer sw_height = 200 ' height
dim integer page1Adr = MM.INFO(PAGE ADDRESS 1)
'box sw_x-2, sw_y-2, sw_width+4, sw_height+4, 2, rgb(red) ' put a box around scroll window

' build custom colours from #100 to #131
for i = 0 to 31
  map(100 + i) = rgb(8*i, 8*i, 8*i)
next i
map set

do
  read txt$
  if txt$ = "END" then exit do
  page write 2
  text 20,0,txt$+space$(75),LT,1   ' 8x12 character
  page write 1
  for i = 1 to 12   ' character height
    blit sw_x,sw_y+1,sw_x,sw_y,sw_width,sw_height-1   ' shift scroll box image up 1
    blit 0,i,sw_x,sw_y+sw_height-1,sw_width,1,2   ' copy row of pixels to bottom of scroll box
    FixColours
    page copy 1,0,B
    pause 40
  next i
  if we.is_quit_pressed%() then exit do
loop

page write 0

we.end_program()

sub FixColours
  local integer i,j

  for i = 0 to 31  ' 5 bit fade region
    FixBytes(page1Adr, sw_x, sw_y+i,sw_width,2,100+i) 'Change all non zero bytes in the row to 100+i
    FixBytes(page1Adr, sw_x, sw_y+sw_height-i,sw_width,1,100+i) 'same change, different row
  next i
end sub

data "BASIC (Beginners' All-purpose Symbolic Instruction Code) is a"
data "family of general-purpose, high-level programming languages"
data "whose design philosophy emphasizes ease of use. The original"
data "version was designed by John G. Kemeny and Thomas E. Kurtz and"
data "released at Dartmouth College in 1964. They wanted to enable"
data "students in fields other than science and mathematics to use"
data "computers. At the time, nearly all use of computers required"
data "writing custom software, which was something only scientists"
data "and mathematicians tended to learn."
data " "
data "In addition to the language itself, Kemeny and Kurtz developed"
data "the Dartmouth Time Sharing System (DTSS), which allowed multiple"
data "users to edit and run BASIC programs at the same time. This"
data "general model became very popular on minicomputer systems like"
data "the PDP-11 and Data General Nova in the late 1960s and early"
data "1970s. Hewlett-Packard produced an entire computer line for this"
data "method of operation, introducing the HP2000 series in the late"
data "1960s and continuing sales into the 1980s. Many early video"
data "games trace their history to one of these versions of BASIC."
data " "
data "The emergence of early microcomputers in the mid-1970s led to"
data "the development of a number of BASIC dialects, including"
data "Microsoft BASIC in 1975. Due to the tiny main memory available"
data "on these machines, often 4 kB, a variety of Tiny BASIC dialects"
data "was also created. BASIC was available for almost any system of"
data "the era, and naturally became the de facto programming language"
data "for the home computer systems that emerged in the late 1970s."
data "These machines almost always had a BASIC interpreter installed"
data "by default, often in the machine's firmware or sometimes on a"
data "ROM cartridge."
data " "
data " "
data " "
data " "
data " "
data " "
data " "
data " "
data " "
data " "
data " "
data " "
data " "
data " "
data " "
data " "
data " "
data "END"

' FixBytes(scrPage%, x%, y%, w%, h%, newColor%)
'
' Sets any non-zero bytes within a bounding box to 'newColor'.
' Only works for 800 pixel wide, 8-bit modes, i.e. Mode 1, 8
'
CSUB FixBytes
 00000000
 4FF0E92D F8DD9C09 6826E028 469CB346 4693681B 0800F04F 7948F44F F8DB461A
 680C7000 68034447 4707FB09 B19A441F 1CB41E7E F1067875 1BE40A01 F8DEB145
 70733000 2000F8DC D2034294 E7F04656 D3FB4294 681E9B09 0801F108 D3DE45B0
 8FF0E8BD
END CSUB
