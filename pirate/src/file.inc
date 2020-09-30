' Copyright (c) 2020 Thomas Hugo Williams
' For Colour Maximite 2, MMBasic 5.05

Const FIL.PROG_DIR$ = fil.get_parent$(Mm.Info$(Current))

' Gets the parent directory of 'f$', or the empty string if it does not have one.
Function fil.get_parent$(f$)
  Local i%

  For i% = Len(f$) To 1 Step -1
    If InStr("/\", Mid$(f$, i%, 1)) > 0 Then Exit For
  Next i%

  If i% > 0 Then fil.get_parent$ = Left$(f$, i% - 1)
End Function

Function fil.get_name$(f$)
  Local i%

  For i% = Len(f$) To 1 Step -1
    If InStr("/\", Mid$(f$, i%, 1)) > 0 Then Exit For
  Next i%

  fil.get_name$ = Mid$(f$, i% + 1)
End Function

' Does the file/directory 'f$' exist?
'
' @return 1 if the file exists, otherwise 0
Function fil.exists%(f$)
  fil.exists% = LCase$(Dir$(f$, ALL)) = LCase$(fil.get_name$(f$))
End Function

' Makes directory 'f$' if it does not already exist.
Sub fil.mkdir(f$)
  If Not fil.exists%(f$) Then MkDir f$
End Sub
