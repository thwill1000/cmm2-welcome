' Copyright (c) 2019-20 Thomas Hugo Williams
' For Colour Maximite 2, MMBasic 5.05

Function str.rpad$(s$, x%)
  If Len(s$) < x% Then
    str.rpad$ = s$ + Space$(x% - Len(s$))
  Else
    str.rpad$ = s$
  EndIf
End Function

' Returns the next space separated token from a string.
' Any excess spaces are ignored, empty tokens are never returned
' except when there are no tokens remaining.
'
' @param[in, out]  on input the string,
'                  on output the remainder of the string after the
'                  next token has been returned.
' @return          the next token, or the empty string if there are
'                  no more tokens.
Function str.next_token$(s$)
  Local en, st = 1
  Do
    en = InStr(st, s$, " ")
    If en < 1 Then
      str.next_token$ = Mid$(s$, st)
      s$ = ""
      Exit Function
    EndIf

    If en = st Then
      st = st + 1
    Else
      str.next_token$ = Mid$(s$, st, en - st)
      s$ = Mid$(s$, en)
      Exit Function
    EndIf
  Loop
End Function
