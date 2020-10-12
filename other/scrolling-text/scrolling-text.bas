'Scrolling Fading Text Demo
'By vegipete
'Made possible with CSUB by The Sasquatch
'www.thebackshed.com/forum/ViewTopic.php?FID=16&TID=12876

Mode 1,8

page write 2 : cls
page write 1 : cls
page write 0 : cls

dim integer sw_x = 100      ' scroll window x location
dim integer sw_y = 100      ' y location
dim integer sw_width = 550  ' width
dim integer sw_height = 200 ' height

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
   pause 50
 next i
loop

page write 0
end

sub FixColours
 local integer i,j

 for i = 0 to 31  ' 5 bit fade region
   FixBytes(sw_x, sw_y+i,sw_width,2,100+i) 'Change all non zero bytes in the row to 100+i
   FixBytes(sw_x, sw_y+sw_height-i,sw_width,1,100+i) 'same change, different row
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

'Graphic Color Changing Subroutines
'By The Sasquatch
'As requested by thwill and vegipete
'www.thebackshed.com
'
'File graphsubs.bas written 08-10-2020 12:31:44
'FixBytes(x,y,h,w,New_Byte)
'Changes any non-zero Bytes within the bounding box to New_Byte
'For a line, set h or v to 1 set w and h to 0 for full screen
'WARNING only works correctly in 8 bit color modes -
'will not work properly in "pixel doubled" modes
CSUB FixBytes
 00000000
 4FF0E92D B085681B 68006815 182F6809 EB03431D 92010201 42B8D013 4291DC0E
 DC0B4614 681B4B35 3B01681B D3054283 68124A33 3A016812 D258428A E8BDB005
 4B2E8FF0 681B4A2E 681B6812 3B016812 2B003A01 9201461F 2A00DBF0 4628DBEE
 42914611 75E5EA25 4611BF28 EA20429F BF2872E0 428D461F 92029101 4B21DADE
 681B42BA DAD9681E F8DF4253 F8DF8070 9300907C F8DF1ABB 9303B078 463D462B
 9B00461F F1039C02 F8D80A01 EB0A3000 4A150004 FB09681B FB03F000 34014307
 B1115CF1 6809990E EBBB54F1 D2010FB0 47986813 D1E842A5 37019B00 44139A03
 9B019300 D1DC42BB E8BDB005 2F008FF0 2C00DBA4 460DDBA2 E7B24621 080002EC
 080002F0 08000358 0800033C 3AFB7E91 001A36E2
End CSUB
