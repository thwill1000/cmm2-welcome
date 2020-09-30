' Scott Adams Adventure Game Interpreter for Colour Maximite 2
' Original TRS-80 Level II BASIC code (c) Scott Adams 1978
' MMBasic port for CMM2 by Thomas Hugo Williams 2020

Dim il ' Highest numbered object 0..il
Dim cl ' Highest action number 0..cl
Dim nl ' Highest vocabulary number 0..nl
Dim rl ' Highest room number 0..rl
Dim mx ' Maximum number of objects carried
Dim ar ' Starting room
Dim tt ' Number of treasures
Dim ln ' Word length
Dim lt ' Time limit
Dim ml ' Highest message number
Dim tr ' Treasure room

Sub adv.read(f$)
  Open f$ For Input AS 1

  Input #1, il, cl, nl, rl, mx, ar, tt, ln, lt, ml, tr

  Dim ca(cl, 7)      ' action table
  Dim nv_str$(nl, 1) ' vocabulary table - verbs at index 0, nouns at index 1
  Dim ia_str$(il)    ' object descriptions
  Dim ia(il)         ' object locations
  Dim i2(il)         ' backup copy of object locations
  Dim rs$(rl)        ' room descriptions
  Dim rm(rl, 5)      ' room exits: N, S, E, W, U, D
  Dim ms$(ml)        ' messages table

  Local i, j

  ' Read action table.
  For i = 0 To cl Step 2
    j = i + 1
    Input #1,ca(i,0),ca(i,1),ca(i,2),ca(i,3),ca(i,4),ca(i,5),ca(i,6),ca(i,7),ca(j,0),ca(j,1),ca(j,2),ca(j,3),ca(j,4),ca(j,5),ca(j,6),ca(j,7)
  Next i

  ' Read vocabulary table.
  For i = 0 To nl Step 10
    For j = 0 TO 1
      Input #1,nv_str$(i,j),nv_str$(i+1,j),nv_str$(i+2,j),nv_str$(i+3,j),nv_str$(i+4,j),nv_str$(i+5,j),nv_str$(i+6,j),nv_str$(i+7,j),nv_str$(i+8,j),nv_str$(i+9,j)
    Next j
  Next i

  ' Read rooms.
  For i = 0 TO rl : Input #1, rm(i,0),rm(i,1),rm(i,2),rm(i,3),rm(i,4),rm(i,5),rs$(i) : Next i

  ' Read messages.
  For i = 0 TO ml : Line Input #1, ms$(i) : Next i

  ' Read objects.
  For i = 0 TO il : Input #1, ia_str$(i),ia(i) : i2(i)=ia(i) : Next i

  Close #1
End Sub
