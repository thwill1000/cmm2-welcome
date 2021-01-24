option explicit

#Include "../../../common/welcome.inc"

mode 1,16

const midscreenx=mm.hres/2
const midscreeny=mm.vres/2
const screeny=mm.vres
const font_h=mm.info(fontheight)

'size is the x and y dimensions of the whole height map grid
'anything over about 70 starts to take ages to calculate
dim size as integer = 150

'grid is the actual height map array
dim grid(size,size) as float

'density sets how much terrain is generated - lower=flat ; higher=mountainous
dim density as float = 13/size

'scz is the number of tiles visible on screen
'anything over about 30 starts to get painfully slow to redraw!
dim scz as integer = 16

'this is the screen scale to work out how big to draw the triangles
dim scr_scl=384/scz
'angle is the projection angle. 0 is side-on, 30 is isometric, 45 is plan / map view
dim angle as float = 30
dim yscale as float       'calculated from the projection angle
dim hproj_scale as float  'calculated from the projection angle
dim bSize as float
dim numBlocks as float
dim x,y as integer
dim maxHeight as integer
dim x1(1),x2(1),x3(1) as integer      'temp arrays to hold 2 x triangles drawn per cell
dim y1(1),y2(1),y3(1) as integer
dim cc(1) as integer                  'cc(0) is the colour of tri 1 ; cc(1) is the col of tri 2
dim pixelx,pixely as integer
dim sx1(scz*scz*2+2),sx2(scz*scz*2+2),sx3(scz*scz*2+2)  'screen (x,y) arrays for drawing
dim sy1(scz*scz*2+2),sy2(scz*scz*2+2),sy3(scz*scz*2+2)  'tris (x 2 tris to draw per grid square)
dim sc(scz*scz*2+2)                                     'rgb colour of tri
'set initial position of screen area to draw
dim px,py
dim msy,ys,hs
'these are the initial rgb colour scalings to generate the height shadings
dim r_offset=-5
dim g_offset=25
dim b_offset=-205
'water is the height of the water table
dim water as integer = 0
dim water_colour=rgb(0,0,128)
'cliff is the minimum height difference in cell vertices to qualify as a cliff
dim cliff as integer = 10
dim max_steep as integer
dim cliff_col
dim a$
'finished setting up vars

'set up initial map
calc_proj(angle)
if size<4 then size=4
if size>200 then size=200
make_random_grid(size)
set_water_level
calc_grid
get_max_steep
calc_colours
a$=inkey$

'main loop
do while a$<>"q"
  cls
  page write 1
  draw_grid
  text 550,550,"Height map size="+str$(size)+","+str$(size)
  text 550,550+font_h,"max height="+str$(maxHeight)
  text 550,550+font_h*2,"max steep="+str$(max_steep)
  text 550,550+font_h*3,"current x,y="+str$(px)+","+str$(py)
  text 0,450,"KEYS"
  text 0,450+font_h*1," Q : quit"
  text 0,450+font_h*2,"-/+: view angle down/up: "+str$(angle)
  text 0,450+font_h*3," n : new map"
  text 0,450+font_h*4," p : smooth map"
  text 0,450+font_h*5,"w/s: red up/down: "+str$(r_offset)
  text 0,450+font_h*6,"e/d: green up/down: "+str$(g_offset)
  text 0,450+font_h*7,"r/f: blue up/down: "+str$(b_offset)
  text 0,450+font_h*8,"t/g: water up/down: "+str$(water) 
  text 0,450+font_h*9,"y/h: map gen density u/d: "+str$(density)
  text 0,450+font_h*10,"o/l: cliff threshold: "+str$(cliff)
  text 0,450+font_h*11,"num pad 1,7,9,3: movement"
  page copy 1 to 0

wait:
  a$=inkey$
  if a$="" then goto wait:
  'check for key pressed
  if a$="-" then angle=angle-5: calc_proj(angle): calc_grid
  if a$="=" then angle=angle+5: calc_proj(angle): calc_grid
  if a$="n" then make_random_grid(size): calc_grid: water=0: set_water_level: get_max_steep: calc_colours
  if a$="p" then smooth_map:set_water_level:calc_grid: calc_colours
  if a$="w" then r_offset=r_offset+5: calc_colours
  if a$="s" then r_offset=r_offset-5: calc_colours
  if a$="e" then g_offset=g_offset+5: calc_colours
  if a$="d" then g_offset=g_offset-5: calc_colours
  if a$="r" then b_offset=b_offset+5: calc_colours
  if a$="f" then b_offset=b_offset-5: calc_colours
  if a$="t" then water=water+1: set_water_level: calc_grid:get_max_steep: calc_colours
  if a$="g" then water=water-1: set_water_level: calc_grid:get_max_steep: calc_colours
  if a$="y" then density=density+.02: make_random_grid(size): calc_grid: get_max_steep: calc_colours
  if a$="h" then density=density-.02: make_random_grid(size): calc_grid: get_max_steep: calc_colours
  if a$="o" then cliff=cliff+1: calc_colours
  if a$="l" then cliff=cliff-1: calc_colours
  if a$="9" then py=py-1: update_pos
  if a$="1" then py=py+1: update_pos
  if a$="7" then px=px-1: update_pos
  if a$="3" then px=px+1: update_pos

loop 'end of main loop

page write 0
we.end_program()

sub update_pos
  if py<0 then py=0
  if py>size-scz then py=size-scz
  if px<0 then px=0
  if px>size-scz then px=size-scz
  calc_grid
  calc_colours
end sub

'calculate the projection angle scales
sub calc_proj(a)
  if a<0 then a=0
  if a>45 then a=45
  hproj_scale=cos(a*2*0.017453) 'this is how much vertical height is visible
  yscale=tan(a*0.017453) 'convert angle degrees to radians
end sub

sub smooth_map
  text 0,20,"smoothing height map vertices"
  for y=1 to size-1
    for x=1 to size-1
      grid(x,y)=(grid(x-1,y-1)+grid(x,y-1)+grid(x+1,y-1)+grid(x-1,y)+grid(x,y)+grid(x+1,y)+grid(x-1,y+1)+grid(x,y+1)+grid(x+1,y+1))/9
    next x
  next y
end sub

sub set_water_level
  text 0,20,"setting water level"
  for y=0 to size
    for x=0 to size
      if grid(x,y)<water then grid(x,y)=water
    next x
  next y
end sub

'create perlin noise height map on the grid
sub make_random_grid(grid_size)
  local id as float = density
  text 0,20,"generating random height map grid"

  'zero the grid
  for y=0 to grid_size
    for x=0 to grid_size
      grid(x,y)=0
    next x
  next y

  maxHeight=0
  bSize=grid_size/2
  do while bSize>0.999  
    numBlocks=grid_size/bsize
    for y = 0 to numBlocks-1
      for x = 0 to numBlocks-1
        if rnd<id then raiseBlock(x,y)
      next x
    next y
    id=id*1.2 'increase the density of smaller block sizes
    
    bSize=bSize/2
  loop
end sub

'raise the height of a block of vertices in the height map
sub raiseBlock(x,y)
  local raise_amount,hbx,hby,sy,sx,iy,ix,rX,rY,height as integer
  sy=y*bSize
  sx=x*bSize
  for rY = 0 to bSize-1
    iy=sy+rY
    for rX = 0 to bSize-1
      ix=sx+rX
      if bSize<size/4 then raise_amount=bSize else raise_amount=bSize/2
      height=grid(ix,iy)+raise_amount
      if height>maxHeight then maxHeight=height
      grid(ix,iy)=height
    next rX
  next rY
  'raise 4 x half size blocks around the large one
  raise_amount=raise_amount/2
  hbx=sx+bSize/4
  hby=sy-bSize/2
  raiseHalfBlock(hbx,hby,raise_amount)
  hbx=sx+bSize
  hby=sy+bSize/4
  raiseHalfBlock(hbx,hby,raise_amount)
  hbx=sx+bSize/4
  hby=sy+bSize
  raiseHalfBlock(hbx,hby,raise_amount)
  hbx=sx-bSize/2
  hby=sy+bSize/4
  raiseHalfBlock(hbx,hby,raise_amount)
end sub

sub raiseHalfBlock(x,y,r)
  local iy,ix as integer
  for iy=y to y+bSize/2-1
    for ix=x to x+bSize/2-1
      if iy>size or iy<0 or ix>size or ix<0 goto skip_half_block:
      grid(ix,iy)=grid(ix,iy)+r
      skip_half_block:
    next ix
  next iy
end sub

'determine maximum steepness
sub get_max_steep
  local steep1,steep2
  for y=0 to size-1
    for x=0 to size-1
      steep1=abs(grid(x,y)-grid(x+1,y+1))
      steep2=abs(grid(x+1,y)-grid(x,y+1))
      if steep1>max_steep then max_steep=steep1
      if steep2>max_steep then max_steep=steep2
    next x
  next y 
end sub


'calculate screen(x,y) for each height map vertex
sub calc_grid
  local tri as integer = 0
  for y=py to py+scz-1
    for x=px to px+scz-1
      'get pixels puts the screen (x,y) vals into the 2 tris xn(0),yn(0) and xn(1),yn(1)
      get_pixels(x,y,1)
      write_tris(tri)
      tri=tri+2
    next x
    'close off the right hand edge of the terrain with 2 triangles down to height 0
'    get_pixels(scz,y,0)
'    sc(tri)=rgb(30,30,30)
'    sc(tri+1)=rgb(30,30,30)
'    write_tris(tri)
  next y
end sub

sub write_tris(t)
      sx1(t)=x1(0)
      sy1(t)=y1(0)
      sx2(t)=x2(0)
      sy2(t)=y2(0)
      sx3(t)=x3(0)
      sy3(t)=y3(0)
      t=t+1
      sx1(t)=x1(1)
      sy1(t)=y1(1)
      sx2(t)=x2(1)
      sy2(t)=y2(1)
      sx3(t)=x3(1)
      sy3(t)=y3(1)
      t=t+1
end sub

'calculate r,g,b for each vertex of the height map
sub calc_colours
  local tri as integer = 0
  for y=py to py+scz-1
    for x=px to px+scz-1
      if grid(x,y)<=water and grid(x+1,y)<=water and grid(x,y+1)<=water then sc(tri)=water_colour:goto skip1:
      sc(tri)=get_col(x,y)
      skip1:
      tri=tri+1
      if grid(x,y+1)<=water and grid(x+1,y)<=water and grid(x+1,y+1)<=water then sc(tri)=water_colour:goto skip2:
      sc(tri)=sc(tri-1)
      skip2:
      tri=tri+1
    next x
  next y
end sub
      
'draw the grid
sub draw_grid
  triangle sx1(),sy1(),sx2(),sy2(),sx3(),sy3(),sc(),sc()
end sub

'this subroutine converts height map vertex position into screen values for 2 triangles
'into screen (x,y) for 2 triangles x1/2/3(0),y1/2/3(0) and x1/2/3(1),y1/2/3(1)
sub get_pixels(gx,gy,h)
  msy=midscreeny-(midscreeny*yscale)
  ys=yscale*scr_scl
  hs=hproj_scale*scr_scl
  'triangle 1
  get_px(gx,gy,h)
  x1(0) = pixelx
  y1(0) = pixely
  get_px(gx+1,gy,h)
  x2(0) = pixelx
  y2(0) = pixely
  gy=gy+1
  get_px(gx,gy,h)
  x3(0) = pixelx
  y3(0) = pixely
  'triangle 2
  x1(1) = x3(0)
  y1(1) = y3(0)
  x2(1) = x2(0)
  y2(1) = y2(0)
  get_px(gx+1,gy,h)
  x3(1) = pixelx
  y3(1) = pixely
end sub

sub get_px(ix,iy,h)
  'offset draw position for current cursor position
  local dix as integer =ix-px
  local diy as integer =iy-py
  pixelx = midscreenx + (dix * scr_scl) - (diy * scr_scl)
  pixely = msy + (dix * ys) + (diy * ys) - (grid(ix,iy) * hs * h)
end sub


function get_col(gx,gy) as integer
  local avgh,snh,red,grn,blu as float 
  local steep1,steep2,steep as integer
  'see if this cell is steep enough to be a cliff (grey)
  steep1=abs(grid(gx,gy)-grid(gx+1,gy+1))
  steep2=abs(grid(gx+1,gy)-grid(gx,gy+1))
  if steep1>steep2 then steep=steep1 else steep=steep2
 'shade the cell grey according to steepness
  if steep>cliff then set_cliff(steep) : red=cliff_col : grn=cliff_col : blu=cliff_col : goto setcol:
  'find average height of this cell (from 4 vertices)
  avgh=(grid(gx,gy) + grid(gx+1,gy) + grid(gx,gy+1) + grid(gx+1,gy+1))/4
  snh=avgh/maxHeight*255
  red=r_offset+(snh)
  grn=g_offset+(snh)
  blu=b_offset+snh*2
setcol:
  if red>255 then red=255
  if red<0 then red=0
  if grn>255 then grn=255
  if grn<0 then grn=0
  if blu>255 then blu=255
  if blu<0 then blu=0
  get_col=rgb(red,grn,blu)
end function

sub set_cliff(s)
  'the cell gets coloured a lighter shade of grey the steeper it is.
  'steep=20 and above=150,150,150
  'shading to 50,50,50 at minimum steep cliff threshold
  cliff_col=120-((max_steep-s)*2)
  if cliff_col<70 then cliff_col=70
end sub  

sub wait_key
hold_it:
  if inkey$="" then goto hold_it:
wait_release:
  if inkey$<>"" then goto wait_release:
end sub


