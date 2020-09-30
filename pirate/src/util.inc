' Copyright (c) 2020 Thomas Hugo Williams
' For Colour Maximite 2, MMBasic 5.05

' Generates a pseudo random integer between 1 and 'range%' inclusive.
'
' @param  range%  if > 0 then upper bound of generated number,
'                 if = 0 then reinitialises seed based on Timer value,
'                 if < 0 then sets seed to Abs(range%)
Function pseudo%(range%)
  Static x% = Timer ' 7
  Static a% = 1103515245
  Static c% = 12345
  Static m% = 2^31

  If range% = 0 Then
    x% = Timer
  ElseIf range% < 0 Then
    x% = Abs(range%)
  Else
    x% = (a% * x% + c%) Mod m%
    pseudo% = 1 + CInt((range% - 1) * (x% / m%))
  EndIf

End Function
