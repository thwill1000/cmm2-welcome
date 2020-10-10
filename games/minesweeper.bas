'----------------------------------------------------------
' Minesweeper for CMM2
' Rev 1.0.0 William M Leue 9/17/2020
' Rev 1.0.1 10/6/2020
'  centered board, fixed a bug in navigation key detection
'-----------------------------------------------------------

option default integer
option base 1

#Include "../common/welcome.inc"

const NSIZES = 3

const CSIZE = 20
const BWIDTH = CSIZE
const HLWIDTH = 5
const CHLW = 3
const MRAD = 3

const DBH = CSIZE*3
const DBM = 4

const NEUTRAL = 0
const HAPPY = 1
const SAD = 2

const NSEGS = 7
const NFIGS = 10
const SDISW = CSIZE-3
const SDISH = 2*SDISW-7
const SEGW = 3
const SS = 2

const LCOLOR = RGB(70, 70, 70)
const BGCOLOR = RGB(150, 150, 150)
const HLCOLOR = RGB(200, 200, 200)
const MCOLOR = RGB(YELLOW)

const CTLW = 144
const CTLH = 144
const CTLX = 400
const CTLY = 330
const CTLX2 = 10
const CTLX3 = 170
const CTLK = 36

const NKEYS = 22

const NORTH = 1
const SOUTH = 2
const EAST = 3
const WEST = 4

' board cell values
' flagged*100 + down*10 + count
const EMPTY     = 0
const MARKED    = 1
const UNMARKED  = 0
const FLAGGED   = 1
const UNFLAGGED = 0
const UP        = 0
const DOWN      = 1

' Not yours but Mine :-)
const MINE = 9

const STKSIZE = 300

' Globals

' These are really constants but BASIC won't allow static init
dim SIZES(2*NSIZES) = (9, 9, 16, 16, 24, 24)
dim NMINES(NSIZES) = (10, 40, 99)
dim DIRS(16) = (-1, -1, 0, -1, 1, -1, -1, 0, 1, 0, -1, 1, 0, 1, 1, 1)
dim WCOLORS(7) = (RGB(BLUE), RGB(GREEN), RGB(RED), RGB(YELLOW), RGB(200, 0, 200), RGB(200, 50, 50), RGB(WHITE))

' real variables
dim difficulty = 0
dim numh = 0
dim numv = 0
dim hmargin = 0
dim vmargin = 0
dim num_mines = 0
dim num_flagged = 0
dim running
dim kvals(NKEYS)
dim curr_row, curr_col
dim board(24, 24)
dim stack(STKSIZE)
dim sptr = 1
dim tinterval = 1000
dim ticks

dim SegCoords(NSEGS, 6, 2)
dim SegActivations(NFIGS, NSEGS)

' Main Program
'open "mdebug.txt" for output as #1
SetUpGraphics
GetKeyData
ReadSegCoords
ReadSegActivations
DrawWelcomeScreen
GetDifficulty
NewGame
PlayLoop
end

' set up graphics mode
sub SetUpGraphics
  mode 1,8
  cls
end sub

' get command key data
sub GetKeyData
  local i, action
  for i = 1 to NKEYS
    read kvals(i)
  next i
end sub

' Play loop
' get command and dispatch to handler
sub PlayLoop
  local key
  local x$
  x$ = INKEY$ ' flush

  do
    do
      x$ = INKEY$
    loop while x$ = ""

    ' HACK! so that "Q" also works as quit for the "Welcome Tape".
    If we.is_quit_key%(x$) Then x$ = "-"

    key = asc(x$)
    action = MapKey(key)
    select case action
      case 1 to 16
        if running then Navigate key
      case 17
        if running then FlagCell curr_col, curr_row
      case 18
        if running then LowerCell curr_col, curr_row
      case 19
        NewGame
      case 20
        Quit
      case 21, 22
        settick 0, TickIntr
        DrawWelcomeScreen
        DrawBoard
        InitDashboard
        DrawDashboard
        settick tinterval, TickIntr
    end select
  loop
end sub

' Map the key value into a command index
function MapKey(key)
  local i
  local action = -1
  for i = 1 to NKEYS
    if kvals(i) = key then
      action = i
      exit for
    end if
  next i
  MapKey = action
end function

' Get the difficulty level from the user
' This also determines the board size and centering margins
sub GetDifficulty
  local ok, bdwidth, bdheight

  cls
  do
    ok = 1
    input "(B)eginner, (I)ntermediate, or (E)xpert: ", ans$
    k$ = LEFT$(UCASE$(ans$), 1)
    if k$ = "B" then
      difficulty = 1
      numh = SIZES(1) : numv = SIZES(2)
    else if k$ = "I" then
      difficulty =2
      numh = SIZES(3) : numv = SIZES(4)
    else if k$ = "E" then
      difficulty = 3
      numh = SIZES(5) : numv = SIZES(6)
    else
      print "Error, please answer with B, I, or E"
      ok = 0
    end if
  loop until ok = 1
  bdwidth = numh*CSIZE
  bdheight = DBH + 2*BWIDTH + numv*CSIZE
  hmargin = (MM.HRES - bdwidth)\2
  vmargin = (MM.VRES - bdheight)\2
end sub

' build a new game
sub NewGame
  local row, col

  cls
  for col = 1 to numh
    for row = 1 to numv
      board(col, row) = EMPTY
    next row
  next col
  PlaceMines
  ComputeWarnings
  DrawBoard
  InitDashboard
  InitNavigation
  num_flagged = 0
  ticks = 0
  settick tinterval, TickIntr
  'PrintBoard 400, 100
  'Cheat
  'PrintBoard 400, 300
  running = 1
end sub

' place the mines
sub PlaceMines
  local row, col, mrow, mcol
  local cell, fv, downv, cnt, np

  num_mines = NMINES(difficulty)
  np = 0
  do while np < num_mines
    mcol = 1 + rnd()*(numh-1)
    mrow = 1 + rnd()*(numv-1)
    if mcol <= numh and mrow <= numv then
      cell = board(mcol, mrow)
      if cell = 0 then
        cell = PackCell(fv, downv, MINE)
        board(mcol, mrow) = cell
        np = np+1
      end if
    end if
  loop
end sub

' debugging tool
sub Cheat
  local col, row, cell, fv, downv, cnt, cell2

  for col = 1 to numh
    for row = 1 to numv
      cell = board(col, row)
      UnpackCell cell, fv, downv, cnt
      if cnt <> MINE then
        cell2 = PackCell(fv, DOWN, cnt)
        board(col, row) = cell2
        DrawCell col, row
      end if
    next row
  next col
end sub

' debugging tool
sub PrintBoard x, y
  local row, col, cell, fv, downv, cnt
  for col = 1 to numh
    for row = 1 to numv
      cell = board(col, row)
      UnpackCell cell, fv, downv, cnt
      text x+18*col, y+15*row, str$(cnt)
    next row
    print ""
  next col
end sub

' compute the warning numbers
' (The mines must have been placed first)
sub ComputeWarnings
  local row, col, cell, d, rinc, cinc, nrow, ncol
  local fv, downv, cnt, ncell, nfv, ndownv, ncnt

  for row = 1 to numv
    for col = 1 to numh
      cell = board(col, row)
      UnpackCell cell, fv, downv, cnt
      if cnt = 0 then
        nw = 0
        for d = 1 to 8
          cinc = DIRS(2*d-1)
          rinc = DIRS(2*d)
          ncol = col + cinc
          nrow = row + rinc
          if ncol >= 1 and ncol <= numh and nrow >= 1 and nrow <= numv then
            ncell = board(ncol, nrow)
            UnpackCell ncell, nfv, ndownv, ncnt
            if ncnt = MINE then
              nw = nw+1
            end if
          end if
        next d
        if nw >= 1 then
          cell = PackCell(fv, downv, nw)
          board(col, row) = cell
        end if
      end if
    next col
  next row
end sub

' Draw the board
sub DrawBoard
  DrawGrid
  DrawDashboard
end sub

' Draw the grid
sub DrawGrid
  local row, col, x, y

  x = hmargin
  y = vmargin
  box x, y, 2*BWIDTH + numh*CSIZE, DBH+2*BWIDTH+numv*CSIZE,, LCOLOR, BGCOLOR
  for row = 1 to numv
    for col = 1 to numh
      DrawCell col, row, UNMARKED
    next col
  next row
  DrawMainBorder hmargin+BWIDTH,  vmargin+DBH+BWIDTH, numh*CSIZE, numv*CSIZE, HLWIDTH, BWIDTH
end sub

' Draw a Board Cell
sub DrawCell col, row, mark
  local x, y, cell, downv, fv, cnt, c

  ' extract parameters
  ' fv: 1 if flagged
  ' downv: 1 if pressed down
  ' cnt: warning or mine value
  cell = board(col, row)
  UnpackCell cell, fv, downv, cnt

  ' draw cell main features
  x = hmargin + col*CSIZE
  y = vmargin + DBH + row*CSIZE
  c = LCOLOR
  if mark = MARKED then
    c = RGB(YELLOW)
  end if
  DrawBlankCell x, y, downv, c

  ' draw various content details
  if downv = DOWN then
    if cnt >= 1 and cnt < MINE then
      DrawWarning col, row
    else if cnt = MINE then
      DrawMine x, y
    end if
  else
    if fv = FLAGGED then
      DrawFlag x, y
    end if
  end if
end sub

' Draw a cell with no flags or warnings;
' those are added later. If the cell
' is currently selected, it will be
' outlined in yellow. It is important
' to draw the raised border before the
' outline gets drawn.
sub DrawBlankCell x, y, downv, c
  box x, y, CSIZE, CSIZE,, LCOLOR, BGCOLOR
  if downv = UP then
    DrawCellBorder x,y
  end if
  box x, y, CSIZE, CSIZE,, c
end sub

' Draw the cell border for 'UP' cells
sub DrawCellBorder x,y
  local xv(5), yv(5)

  xv(1) = x            : yv(1) = y
  xv(2) = x+CSIZE      : yv(2) = yv(1)
  xv(3) = x+CSIZE-CHLW : yv(3) = y+CHLW
  xv(4) = x+CHLW       : yv(4) = yv(3)
  xv(5) = xv(1)        : yv(5) = yv(1)
    polygon 5, xv(), yv(), HLCOLOR, HLCOLOR
  xv(1) = x            : yv(1) = y
  xv(2) = xv(1)        : yv(2) = y+CSIZE
  xv(3) = x+CHLW       : yv(3) = y+CSIZE-CHLW
  xv(4) = xv(3)        : yv(4) = y+CHLW
  xv(5) = xv(1)        : yv(5) = yv(1)
    polygon 5, xv(), yv(), HLCOLOR, HLCOLOR
  xv(1) = x+CSIZE      : yv(1) = y
  xv(2) = xv(1)        : yv(2) = y+CSIZE
  xv(3) = x+CSIZE-CHLW : yv(3) = y+CSIZE-CHLW
  xv(4) = xv(3)        : yv(4) = y+CHLW
  xv(5) = xv(1)        : yv(5) = yv(1)
    polygon 5, xv(), yv(), LCOLOR, LCOLOR
  xv(1) = x            : yv(1) = y+CSIZE
  xv(2) = x+CHLW       : yv(2) = y+CSIZE-CHLW
  xv(3) = x+CSIZE-CHLW : yv(3) = yv(2)
  xv(4) = x+CSIZE      : yv(4) = yv(1)
  xv(5) = xv(1)        : yv(5) = yv(1)
    polygon 5, xv(), yv(), LCOLOR, LCOLOR
end sub

'Draw a border around the main box
sub DrawMainBorder x, y, w, h, hw, bw
  local x1, y1, x2, y2
  local xv(5), yv(5)

  ' inner hilites
  xv(1) = x - hw      : yv(1) = y - hw
  xv(2) = x + w + hw  : yv(2) = yv(1)
  xv(3) = x + w       : yv(3) = y
  xv(4) = x           : yv(4) = y
  xv(5) = xv(1)       : yv(5) = yv(1)
  polygon 5, xv(), yv(), LCOLOR, LCOLOR
  xv(1) = x - hw      : yv(1) = y - hw
  xv(2) = xv(1)       : yv(2) = y + h + hw
  xv(3) = x           : yv(3) = y + h
  xv(4) = x           : yv(4) = y
  xv(5) = xv(1)       : yv(5) = yv(1)
  polygon 5, xv(), yv(), LCOLOR, LCOLOR
  xv(1) = x + w + hw  : yv(1) = y - hw
  xv(2) = xv(1)       : yv(2) = y + h + hw
  xv(3) = x + w       : yv(3) = y + h
  xv(4) = x + w       : yv(4) = y
  xv(5) = xv(1)       : yv(5) = yv(1)
  polygon 5, xv(), yv(), HLCOLOR, HLCOLOR
  xv(1) = x           : yv(1) = y + h
  xv(2) = x + w       : yv(2) = yv(1)
  xv(3) = x + w + hw  : yv(3) = y + h + hw
  xv(4) = x - hw      : yv(4) = yv(3)
  xv(5) = xv(1)       : yv(5) = yv(1)
  polygon 5, xv(), yv(), HLCOLOR, HLCOLOR
  ' outer hilites
  xv(1) = x - bw      : yv(1) = y - bw - dbh
  xv(2) = x - bw + hw : yv(2) = y - bw - dbh + hw
  xv(3) = xv(2)       : yv(3) = y + h + bw - hw
  xv(4) = xv(1)       : yv(4) = y + H + bw
  xv(5) = xv(1)       : yv(5) = yv(1)
  polygon 5, xv(), yv(), HLCOLOR, HLCOLOR
  xv(1) = x+w+bw-hw   : yv(1) = y - bw - dbh + hw
  xv(2) = x+w+bw      : yv(2) = y - bw - dbh
  xv(3) = xv(2)       : yv(3) = y + h + bw
  xv(4) = xv(1)       : yv(4) = y + H + bw - hw
  xv(5) = xv(1)       : yv(5) = yv(1)
  polygon 5, xv(), yv(), LCOLOR, LCOLOR
  xv(1) = x - bw      : yv(1) = y - bw - dbh
  xv(2) = x+w+bw      : yv(2) = yv(1)
  xv(3) = x+w+bw-hw   : yv(3) = y - dbh - bw + hw
  xv(4) = x - bw + hw : yv(4) = yv(3)
  xv(5) = xv(1)       : yv(5) = yv(1)
  polygon 5, xv(), yv(), HLCOLOR, HLCOLOR
  xv(1) = x - bw + hw : yv(1) = y + h + bw - hw
  xv(2) = x+w+bw-hw   : yv(2) = yv(1)
  xv(3) = x+w+bw      : yv(3) = y + h + bw
  xv(4) = x - bw      : yv(4) = yv(3)
  xv(5) = xv(1)       : yv(5) = yv(1)
  polygon 5, xv(), yv(), LCOLOR, LCOLOR

end sub

' Draw the flag indicating where user thinks a mine is located
sub DrawFlag x, y
  local xc, yc
  local xv(4), yv(4)

  xc = x+CSIZE\2 : yc = y + CSIZE\2
  line xc-1, yc-3, xc-1, yc+5, 3, RGB(BLACK)
  line xc-4, yc+5, xc+4, yc+5, 3, RGB(BLACK)
  xv(1) = xc+1  : yv(1) = yc-5
  xv(2) = xv(1) : yv(2) = yc
  xv(3) = xc-7  : yv(3) = yc-2
  xv(4) = xv(1) : yv(4) = yv(1)
  polygon 4, xv(), yv(), RGB(RED), RGB(RED)
end sub

' Draw the warning number for a cell
sub DrawWarning col, row
  local x, y, c

  nw = board(col, row) mod 10
  if nw > 0 then
    c = WCOLORS(nw)
    x = hmargin + BWIDTH + (col-1)*CSIZE + 5
    y = vmargin + DBH + BWIDTH + (row-1)*CSIZE + 5
    text x, y, str$(nw),,,, c, BGCOLOR
  end if
end sub

' Draw the mine in a mined cell
sub DrawMine x, y
  local xc, yc

  box x, y, CSIZE, CSIZE,, LCOLOR, RGB(RED)
  xc = x+CSIZE\2 : yc = y+CSIZE\2
  circle xc, yc, 4,,, RGB(BLACK), RGB(BLACK)
  line xc-6, yc, xc+6, yc, 1, RGB(BLACK)
  line xc, yc-6, xc, yc+6, 1, RGB(BLACK)
end sub

' draw the dashboard at the top
sub DrawDashboard
  local xv(5), yv(5)
  xv(1) = hmargin+numh*CSIZE+2*BWIDTH-HLWIDTH-4
  yv(1) = vmargin+HLWIDTH
  xv(2) = xv(1) : yv(2) = vmargin+DBH+DBM+4
  xv(3) = xv(1)-DBM : yv(3) = yv(2)-DBM
  xv(4) = xv(3): yv(4) = yv(1)+DBM
  xv(5) = xv(1): yv(5) = yv(4)
  polygon 5, xv(), yv(), HLCOLOR, HLCOLOR
  xv(1) = hmargin+HLWIDTH+DBM : yv(1) = vmargin+HLWIDTH+DBM
  xv(2) = hmargin+numh*CSIZE+2*BWIDTH-HLWIDTH-4 : yv(2) = yv(1)
  xv(3) = xv(2)-DBM : yv(3) = yv(2) + 4
  xv(4) = xv(1) : yv(4) = yv(3)
  xv(5) = xv(1) : yv(5) = yv(1)
  polygon 5, xv(), yv(), LCOLOR, LCOLOR
  yv(1) = vmargin+DBH+DBM+4
  yv(2) = yv(1)
  yv(3) = yv(2) - 4
  yv(4) = yv(3)
  yv(5) = yv(1)
  polygon 5, xv(), yv(), HLCOLOR, HLCOLOR
  xv(1) = hmargin+HLWIDTH+DBM : yv(1) = vmargin+HLWIDTH+DBM
  xv(2) = xv(1) : yv(2) = vmargin+DBH+DBM+4
  xv(3) = xv(1)+DBM : yv(3) = yv(2)-DBM
  xv(4) = xv(3) : yv(4) = yv(1)+DBM
  xv(5) = xv(1) : yv(5) = yv(1)
  polygon 5, xv(), yv(), LCOLOR, LCOLOR
end sub

' Initialize Navigation
sub InitNavigation
  curr_row = 1
  curr_col = 1
  MarkCell curr_row, curr_col, MARKED
end sub

' Mark or unmark a cell as the current navigation focus
sub MarkCell col, row, mv
  DrawCell col, row, mv
end sub

' Navigate around the board using WADS, arrow keys, or 8264 keys
sub Navigate key
  local dir = -1
  local nrow, ncol

  nrow = curr_row : ncol = curr_col
  if key = 87 or key = 119 or key = 128 or key = 56 then
    dir = NORTH
    nrow = curr_row-1
    if nrow < 1 then nrow = numv
  else if key = 83 or key = 115 or key = 129 or key = 50 then
    dir = SOUTH
    nrow = curr_row+1
    if nrow > numv then nrow = 1
  else if key = 68 or key = 100 or key = 131 or key = 52 then
    dir = EAST
    ncol = curr_col+1
    if ncol > numh then ncol = 1
  else if key = 65 or key = 97 or key = 130 or key = 54 then
    dir = WEST
    ncol = curr_col-1
    if ncol < 1 then ncol = numh
  end if
  MarkCell curr_col, curr_row, UNMARKED
  MarkCell ncol, nrow, MARKED
  curr_col = ncol : curr_row = nrow
end sub

' Pack various feature values into a board cell
function PackCell(flag, downv, count)
  local cell
  cell = flag*100 + downv*10 + count
  PackCell = cell
end function

' Unpack a board cell into the various features
sub UnpackCell cell, flag, downv, count
  flag = cell \ 100
  downv = (cell - flag*100) \ 10
  count = (cell - flag*100 - downv*10)
end sub

' Raise a flag when the 5 key is pressed
sub FlagCell col, row
  local cell, fv, downv, cnt
  cell = board(col, row)
  UnpackCell cell, fv, downv, cnt
  if downv = DOWN then
    exit sub
  end if
  if fv = FLAGGED then
    cell = PackCell(UNFLAGGED, UP, cnt)
    num_flagged = num_flagged-1
  else
    cell = PackCell(FLAGGED, UP, cnt)
    num_flagged = num_flagged+1
    CheckWin
  end if
  nmleft = num_mines - num_flagged
  if nmleft < 0 then
    nmleft = 0
  end if
  DrawSevenSegNumber 1, nmleft
  board(col, row) = cell
  DrawCell(col, row)
end sub

' Lower the 'water level' of a cell when CR is presssed
' This triggers a flood fill of cells that are adjacent and
' non-mine. The flood stops at board edges and cells with
' warning counts.
sub LowerCell col, row
  local cell, fv, downv, cnt
  cell = board(col, row)
  UnpackCell cell, fv, downv, cnt
  if downv = DOWN then
    exit sub
  else
    cell = PackCell(UNFLAGGED, DOWN, cnt)
    board(col, row) = cell
    DrawCell col, row
    CheckWin
    if cnt = 0 then
      DrainWater col, row
    else if cnt = MINE then
      running = 0
      settick 0, TickIntr
      DrawFace SAD, RGB(BLUE)
      text hmargin+(numh+1)*CSIZE\2, vmargin+DBH+2, "You Lose!", "CB",,, RGB(BLUE), BGCOLOR
      ShowAllMines
      ShowIncorrectFlags
    end if
  end if
end sub

' Quit when the '-' key is pressed
sub Quit
  'close #1
  we.end_program()
end sub

' Iteratively Set cells to 'DOWN' until the border of the
' region containing the specified cell is entirely made up of
' Cells with warning numbers or the board edge.
' The algorithm is a scan-line, nonrecursive flood fill.
sub DrainWater scol, srow
  local col, row
  local cell, fv, downv, cnt, cnt1
  local col1, row1, tflag, bflag

  push scol, srow

  ' repeat so long as there are values on the stack
  do while sptr > 1

    ' each new cell popped from stack will be a new scan line
    pop col, row
    if col < 1 or col > numh then continue do
    if row < 1 or row > numv then continue do
    cell = board(col, row)
    UnpackCell cell, fv, downv, cnt
    col1 = col : ok = 1

    ' process a scan line.
    ' move as far left as possible.
    ' terminate on warning count or mine.
    ' if mine, step to right one cell.
    do while ok = 1
      col1 = col1-1
      if col1 < 1 then
        ok = 0
        col1 = col1+1
      else
        cell = board(col1, row)
        UnpackCell cell, fv, downv, cnt
        if cnt = MINE then
          ok = 0
          col1 = col1-1
        end if
        if cnt > 0 then ok = 0
        if downv <> UP then ok = 0
      end if
    loop

    ' move from left to right
    ok = 1
    eflag = 0
    do while ok = 1
      tflag = 0 : bflag = 0
      if col1 >= 1 and col1 <= numh then
        cell = board(col1, row)
        UnpackCell cell, fv, downv, cnt
        ' terminate scan line when warning count appears
        ' but only when cell is right of starting cell
        if cnt >= 1 and col1 > col then
          ok = 0
          if cnt = MINE then
            col1 = col1-1
          end if
        end if
        ' this is where the hidden cell value is revealed
        if fv = UNFLAGGED then
          cell = PackCell(fv, DOWN, cnt)
          board(col1, row) = cell
          DrawCell col1, row, 0
          CheckWin
        end if

        ' top push
        if row > 1 and ok = 1 then
          cell = board(col1, row-1)
          UnpackCell cell, fv, downv, cnt1
          if tflag = 0 then
            if cnt = 0 and downv = UP then
              push col1, row-1
              tflag = 1
            end if
          else
            if downv <> UP then
              tflag = 0
            end if
          end if
        end if

        ' bottom push
        if row < numv and ok = 1 then
          cell = board(col1, row+1)
          UnpackCell cell, fv, downv, cnt1
          if bflag = 0 then
            if cnt = 0 and downv = UP then
              push col1, row+1
              bflag = 1
            end if
          else
            if downv <> UP then
              bflag = 0
            end if
          end if
        end if
      end if
      col1 = col1+1
      if col1 > numh then
        exit do
      end if
    loop

  loop

end sub

' push a cell onto the stack for the flood fill
sub push col, row
  if sptr >= STKSIZE then
    ERROR "Bug: stack overflow"
  end if
  stack(sptr) = col*100 + row
  sptr = sptr+1
end sub

' pop a cell from the stack for the flood fill
sub pop col, row
  if sptr <= 1 then
    col = -1 : row = -1
    exit sub
  end if
  sptr = sptr-1
  if sptr < 1 then
    ERROR "Bug: stack underflow"
  end if
  col = stack(sptr)\100
  row = stack(sptr)- col*100
end sub

' Check for a won game
' we recalculate the number of flags to count
' only flags that are correctly placed on a mine
sub CheckWin
  local row, col, num
  local cell, fv, downv, cnt
  local dcnt, fcnt

  fcnt = 0 :  dcnt = 0
  for col = 1 to numh
    for row = 1 to numv
      cell = board(col, row)
      UnpackCell cell, fv, downv, cnt
      if downv = DOWN then dcnt = dcnt+1
      if fv = FLAGGED and cnt = MINE then fcnt = fcnt+1
    next row
  next col
  num = dcnt + num_flagged
  'print #1, "fcnt: " + str$(fcnt) + " dcnt: " + str$(dcnt) + " num_mines: " + str$(num_mines)
  'print #1, "total cells: " + str$(numh*numv)
  if fcnt >= num_mines-1 then
    'print #1, "All mines:"
    for col = 1 to numh
      for row = 1 to numv
        cell = board(col, row)
        UnpackCell cell, fv, downv, cnt
        if cnt = MINE then
          if fv = FLAGGED then
            'print #1, "mine at " + str$(col) + "," + str$(row) + " FLAGGED"
          else
            'print #1, "mine at " + str$(col) + "," + str$(row) + " UNFLAGGED"
          end if
        end if
      next row
    next col
    'print #1, "All flags:"
    for col = 1 to numh
      for row = 1 to numv
        cell = board(col, row)
        UnpackCell cell, fv, downv, cnt
        if fv = FLAGGED then
          if cnt = MINE then
            'print #1, "mine at " + str$(col) + "," + str$(row) + " TRUE"
          else
            'print #1, "mine at " + str$(col) + "," + str$(row) + " FALSE"
          end if
        end if
      next row
    next col
  end if
  if num = numh*numv then
    'print #1, "win by all cells cleared"
    running = 0
    settick 0, TickIntr
    DrawFace HAPPY, RGB(GREEN)
    text hmargin+(numh+1)*CSIZE\2, vmargin+DBH+2, "You Win!", "CB",,, RGB(GREEN), BGCOLOR
  else if fcnt = num_mines then
    'print #1, "win by all mines flagged"
    for col = 1 to numh
      for row = 1 to numv
        cell = board(col, row)
        UnpackCell cell, fv, downv, cnt
        if fv = UNFLAGGED then
          cell = PackCell(fv, DOWN, cnt)
          board(col, row) = cell
          DrawCell col, row
        end if
      next row
    next col
    running = 0
    settick 0, TickIntr
    DrawFace Happy, RGB(GREEN)
  end if
end sub

' Show all the unflagged mines when there is a loss
sub ShowAllMines
  local row, col, cell, fv, downv, cnt

  for col = 1 to numh
    for row = 1 to numv
      cell = board(col, row)
      UnpackCell cell, fv, downv, cnt
      if cnt = MINE and fv = UNFLAGGED then
        cell = PackCell(UNFLAGGED, DOWN, cnt)
        board(col, row) = cell
        DrawCell col, row
      end if
    next row
  next col
end sub

' Show the incorrectly-placed flags when there is a loss
sub ShowIncorrectFlags
  local row, col, cell, fv, downv, cnt
  local xc, yc

  for col = 1 to numh
    for row = 1 to numv
      cell = board(col, row)
      UnpackCell cell, fv, downv, cnt
      if fv = FLAGGED and cnt <> MINE then
        xc = hmargin + col*CSIZE + CSIZE\2
        yc = vmargin + DBH + row*CSIZE + CSIZE\2
        line xc-5, yc-5, xc+5, yc+5,, RGB(BLUE)
        line xc+5, yc-5, xc-5, yc+5,, RGB(BLUE)
      end if
    next row
  next col
end sub

' Draw a number with a simulated 3-or-4-digit, 7-segment display
sub DrawSevenSegNumber which, num
  local x, y, digit, seg, active, j, k, c, dindex
  local xv(7), yv(7), digs(4)

  if which = 1 then
    ndigs = 3
  else

    ndigs = 4
  end if
  c = RGB(RED)
  if which = 1 then
    x = hmargin+18
  else
    x = hmargin+(numh-1)*CSIZE-25
  end if
  y = vmargin+19
  box x, y, ndigs*SDISW, SDISH,, RGB(BLACK), RGB(BLACK)

  if num < 1000 then digs(4) = 0 else digs(4) = num\1000
  if num < 100 then digs(3) = 0 else digs(3) = (num-digs(4)*1000)\100
  if num < 10 then digs(2) = 0 else digs(2) = (num - digs(4)*1000-digs(3)*100)\10
  digs(1) = num mod 10

  for digit = 1 to ndigs
    dindex = digs(digit)+1
    for seg = 1 to NSEGS
      active = SegActivations(dindex, seg)
      if active then
        if seg = 4 then k = 6 else k = 4
        for j = 1 to k
          xv(j) = x + (ndigs-digit)*SDISW + SegCoords(seg, j, 1)
          yv(j) = y + SegCoords(seg, j, 2)
        next j
        xv(k+1) = xv(1) : yv(k+1) = yv(1)
        polygon k+1, xv(), yv(), c, c
      end if
    next seg
  next digit
end sub

' Draw a Neutral (0), Happy (1) or Sad (2) Face
sub DrawFace hors, c
  local x, y, xc, yc, e1x, e2x, ey, my

  x = hmargin+(numh*CSIZE)\2 - 7
  y = vmargin+17
  box x, y, 2*(CSIZE-3), 2*(CSIZE-3),, BGCOLOR, BGCOLOR
  xc = x + CSIZE-3 : yc = y + CSIZE-3
  circle xc, yc, CSIZE-6,,, c, c
  e1x = xc-CSIZE\3 : e2x = xc+CSIZE\3 : ey = yc-CSIZE\3
  my = yc+CSIZE\3
  if hors = NEUTRAL then
    circle e1x, ey, 2,,, RGB(BLACK)
    circle e2x, ey, 2,,, RGB(BLACK)
    line xc-7, my, xc+7, my, 1, RGB(BLACK)
  else if hors = HAPPY then
    line e1x, ey, e1x-3, ey+3, 1, RGB(BLACK)
    line e1x, ey, e1x+3, ey+3, 1, RGB(BLACK)
    line e2x, ey, e2x-3, ey+3, 1, RGB(BLACK)
    line e2x, ey, e2x+3, ey+3, 1, RGB(BLACK)
    line xc-5, my, xc+5, my, 1, RGB(BLACK)
    line xc-5, my, xc-7, my-2, 1, RGB(BLACK)
    line xc+5, my, xc+7, my-2, 1, RGB(BLACK)
  else
    line e1x, ey, e1x-3, ey-3, 1, RGB(BLACK)
    line e1x, ey, e1x+3, ey-3, 1, RGB(BLACK)
    line e2x, ey, e2x-3, ey-3, 1, RGB(BLACK)
    line e2x, ey, e2x+3, ey-3, 1, RGB(BLACK)
    line xc-5, my, xc+5, my, 1, RGB(BLACK)
    line xc-5, my, xc-7, my+2, 1, RGB(BLACK)
    line xc+5, my, xc+7, my+2, 1, RGB(BLACK)
  end if
end sub

' Initialize the dashboard
sub InitDashboard
  DrawFace NEUTRAL, RGB(YELLOW)
  DrawSevenSegNumber 1, num_mines
  DrawSevenSegNumber 2, ticks
end sub

' ISR for the 1-second ticker that updates the right-hand
' digital counter in the dashboard.
sub TickIntr
  ticks = ticks+1
  DrawSevenSegNumber 2, ticks
end sub

' Draw the welcome screen that shows the controls
sub DrawWelcomeScreen
  cls
  print "Welcome to Minesweeper for CMM2!"
  print "This is inspired by the classic MS Minesweeper."
  print "The picture and text below show the controls."
  print "You can return to this screen any time by pressing '?'.
  print "Press '?' again to return to your game."
  print ""
  print "Instead of a mouse, you use keyboard keys to navigate"
  print "around the board and perform functions."
  print ""
  print "Keys shown in YELLOW are the navigation keys."
  print "You can use either the WASD, arrow keys, or the 2468 keypad keys"
  print "to navigate around the board. A yellow square shows you the"
  print "currently-selected square."
  print ""
  print "Use the '5' key (blue) to raise or lower a flag where you think"
  print "a mine might be located. Use either Enter key to reveal the"
  print "contents of the square, but if you uncover a mine instead of
  print "flagging it, you lose!"
  print ""
  print "Flag all mines and uncover all the other squares to win the game"
  print "The left-hand number display shows how many mines remain to flag."
  print "The right-hand number shows the number of seconds you have used."
  print "The face in the center begins with a 'neutral' expression, which"
  print "changes to a happy face when you win and a sad face when you lose."

  ShowControls

  text 0, 550, ""
  print "Enjoy!"
  print "Press any key to exit this screen."

  we.clear_keyboard_buffer()
  qx$ = we.wait_for_key$()
  If we.is_quit_pressed%() Or qx$ = "-" Then we.end_program()

  cls
end sub

sub ShowControls
  local row, col, cx, ry, tx, ty, c

  ' Show WASD navigation controls
  col = 2
  row = 1
  cx = CTLX2+col*CTLK
  ry = CTLY + row*CTLK
  c = RGB(YELLOW)
  rbox cx, ry, CTLK, CTLK,, RGB(YELLOW)
  text cx+CTLK\2, ry+CTLK\2+5, "W", "CB",,, RGB(YELLOW)
  col = 1
  cx = CTLX2+col*CTLK
  row = 2
  ry = CTLY + row*CTLK
  rbox cx, ry, CTLK, CTLK,, RGB(YELLOW)
  text cx+CTLK\2, ry+CTLK\2+5, "A", "CB",,, RGB(YELLOW)
  col = 2
  cx = CTLX2+col*CTLK
  rbox cx, ry, CTLK, CTLK,, RGB(YELLOW)
  text cx+CTLK\2, ry+CTLK\2+5, "S", "CB",,, RGB(YELLOW)
  col = 3
  cx = CTLX2+col*CTLK
  rbox cx, ry, CTLK, CTLK,, RGB(YELLOW)
  text cx+CTLK\2, ry+CTLK\2+5, "D", "CB",,, RGB(YELLOW)

  ' Show arrow key controls
  col = 2
  row = 3
  cx = CTLX3+col*CTLK
  ry = CTLY + row*CTLK
  rbox cx, ry, CTLK, CTLK,, RGB(YELLOW)
  text cx+CTLK\2, ry+CTLK\2+5, chr$(146), "CB",,, RGB(YELLOW)
  col = 1
  row = 4
  cx = CTLX3+col*CTLK
  ry = CTLY + row*CTLK
  rbox cx, ry, CTLK, CTLK,, RGB(YELLOW)
  text cx+CTLK\2, ry+CTLK\2+5, chr$(149), "CB",,, RGB(YELLOW)
  col = 2
  cx = CTLX3+col*CTLK
  ry = CTLY + row*CTLK
  rbox cx, ry, CTLK, CTLK,, RGB(YELLOW)
  text cx+CTLK\2, ry+CTLK\2+5, chr$(147), "CB",,, RGB(YELLOW)
  col = 3
  cx = CTLX3+col*CTLK
  ry = CTLY + row*CTLK
  rbox cx, ry, CTLK, CTLK,, RGB(YELLOW)
  text cx+CTLK\2, ry+CTLK\2+5, chr$(148), "CB",,, RGB(YELLOW)


  ' Show numeric keypad controls
  text CTLX3+CTLW\2, CTLY+50, "Controls", "CB"
  for row = 0 to 4
    ry = CTLY+row*CTLK
    for col = 0 to 3
      cx = CTLX+col*CTLK
      c = RGB(WHITE)
      if row = 1 and col = 3 then
        rbox cx, ry, CTLK, 2*CTLK,, RGB(GREEN)
        text cx+CTLK\2, ry+CTLK, "+", "CB",,, RGB(GREEN)
        text CTLX+CTLW+10, ry+CTLK, "New Game", "LT",,, RGB(GREEN)
      else if row = 2 and col = 3 then
        ' skip
      else if row = 3 and col = 3 then
        rbox cx, ry, CTLK, 2*CTLK,, RGB(CYAN)
        text cx+CTLK\2, ry+5, "Enter", "CTV",,, RGB(CYAN)
      else if row = 4 and col = 3 then
        ' skip
      else if row = 4 and col = 0 then
        rbox cx, ry, 2*CTLK, CTLK,, c
        text cx+CTLK, ry+10, "0", "CT"
      else if row = 4 and col = 1 then
        ' skip
      else
        c = RGB(WHITE)
        if row = 0 and col = 3 then c = RGB(RED)
        if row = 1 and col = 1 then c = RGB(YELLOW)
        if row = 2 and col = 0 then c = RGB(YELLOW)
        if row = 2 and col = 2 then c = RGB(YELLOW)
        if row = 3 and col = 1 then c = RGB(YELLOW)
        if row = 2 and col = 1 then c = RGB(BLUE)

        rbox cx, ry, CTLK, CTLK,, c
        tx = cx + 17
        ty = ry + 23
        select case row
          case 0
            select case col
              case 0 : text tx, ty, "NL", "CB"
              case 1 : text tx, ty, "/", "CB"
              case 2 : text tx, ty, "*", "CB"
              case 3 : text tx, ty, "-", "CB",,, RGB(RED)
            end select
          case 1
            select case col
              case 0 : text tx, ty, "7", "CB"
              case 1 : text tx, ty, "8", "CB",,, RGB(YELLOW)
              case 2 : text tx, ty, "9", "CB"
            end select
          case 2
            select case col
              case 0 : text tx, ty, "4", "CB",,, RGB(YELLOW)
              case 1 : text tx, ty, "5", "CB",,, RGB(BLUE)
              case 2 : text tx, ty, "6", "CB",,, RGB(YELLOW)
            end select
          case 3
            select case col
              case 0 : text tx, ty, "1", "CB"
              case 1 : text tx, ty, "2", "CB",,, RGB(YELLOW)
              case 2 : text tx, ty, "3", "CB"
            end select
        end select
      end if
    next col
  next row
  text CTLX-50, CTLY+2*CTLK+CTLK\2, "FLAG", "LT",,, RGB(BLUE)
  text CTLX+CTLW+10, CTLY, "QUIT", "LT",,, RGB(RED)
  text CTLX+TCLW+4*CTLK+10, CTLY+4*CTLK, "Reveal", "LT",,, RGB(CYAN)
end sub

' read the coordinates for the 7-segment numeric displays
sub ReadSegCoords
  local seg, i, j, k

  for seg = 1 to NSEGS
    k = 4
    if seg = 4 then k = 6
    for i = 1 to k
      for j = 1 to 2
        read SegCoords(seg, i, j)
      next j
    next i
  next seg
end sub

' Read the segment activations for the seven-segment display
' for the digits 0..9
sub ReadSegActivations
  local seg, i

  for i = 1 to NFIGS
    for seg = 1 to NSEGS
      read SegActivations(i, seg)
    next seg
  next i
end sub

' Keyboard ASCII values for control keys
data 87, 83, 68, 65, 119, 115, 100, 115, 128, 129, 131, 130, 56, 50, 54, 52, 53, 10, 43, 45, 47, 63

' Seven-segment display segment polygons (relative to bounding box)
data SS, SS, SDISW-SS, SS, SDISW-SS-SEGW, SS+SEGW, SS+SEGW, SS+SEGW
data SS, SS, SS, SDISH\2, SS+SEGW, SS+SDISH\2-SEGW, SS+SEGW, SS+SEGW
data SDISW-SS, SS, SDISW-SS, SS+SDISH\2, SDISW-SS-SEGW, SS+SDISH\2-SEGW, SDISW-SS-SEGW, SS+SEGW

data SS+SEGW, SS+SDISH\2-SEGW\2, SS, SS+SDISH\2, SS+SEGW, SS+SDISH\2+SEGW\2
data SDISW-SS-SEGW, SS+SDISH\2+SEGW\2, SDISW-SS, SS+SDISH\2, SDISW-SS-SEGW, SS+SDISH\2-SEGW\2

data SS, SS+SDISH\2, SS, SDISH-SS, SS+SEGW, SS+SDISH-SS-SEGW, SS+SEGW, SS+SDISH\2+SEGW
data SDISW-SS, SS+SDISH\2, SDISW-SS, SDISH-SS, SDISW-SS-SEGW, SDISH-SS-SEGW, SDISW-SS-SEGW, SS+SDISH\2+SEGW
data SS, SDISH-SS, SDISW-SS, SDISH-SS, SDISW-SS-SEGW, SDISH-SS-SEGW, SS+SEGW, SDISH-SS-SEGW

' Seven-segment activation list for numbers 0 through 9
data 1, 1, 1, 0, 1, 1, 1
data 0, 1, 0, 0, 1, 0, 0
data 1, 0, 1, 1, 1, 0, 1
data 1, 0, 1, 1, 0, 1, 1
data 0, 1, 1, 1, 0, 1, 0
data 1, 1, 0, 1, 0, 1, 1
data 1, 1, 0, 1, 1, 1, 1
data 1, 0, 1, 0, 0, 1, 0
data 1, 1, 1, 1, 1, 1, 1
data 1, 1, 1, 1, 0, 1, 1
