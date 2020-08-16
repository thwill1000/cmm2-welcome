' Author: Thomas Hugo Williams

Const VERSION$ = "Version 0.1"

' Gets the parent directory of 'f$', of the empty string if it does not have one.
Function get_parent$(f$)
  Local i

  For i = Len(f$) To 1 Step -1
    If InStr("/\", Mid$(f$, i, 1)) > 0 Then Exit For
  Next i

  If i = 0 Then
    get_parent$ = ""
  Else
    get_parent$ = Left$(f$, i - 1)
  EndIf
End Function

