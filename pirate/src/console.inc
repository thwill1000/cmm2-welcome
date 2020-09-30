' Copyright (c) 2019-20 Thomas Hugo Williams
' For Colour Maximite 2, MMBasic 5.05

Dim con.buf$   ' console write buffer
Dim con.space  ' was the last character written to con.buf$ a space?
Dim con.lines  ' number of lines that have been output since the last prompt
Dim con.count  ' number of consecutive calls to con.endl() without an
               ' intervening call to con.print()
Dim con.x = 1  ' current horizontal cursor position, indexed from 1
Dim con.spin   ' is the spinning cursor currently displayed?
Dim con.fd_in  ' file descriptor to read input from
Dim con.fd_out ' file descriptor to echo input to

'!comment_if INLINE_CONSTANTS
Dim CON.HEIGHT = 50
Dim CON.WIDTH = 100
'!endif

' @param  p$  prompt
Function con.in$(p$, echo)
  Local s$

  con.print(p$)
  con.flush()

  Line Input #con.fd_in, s$
  If con.fd_in > 0 Then con.println(s$)
  con.lines = 0
  con.x = 1
  If con.fd_in > 0 Then
    If Eof(#con.fd_in) Then Close #con.fd_in : con.fd_in = 0
  EndIf

  If echo Then
    If con.fd_out > 0 Then
      If s$ <> "" Then Print #con.fd_out, s$
    EndIf
  EndIf

  con.in$ = s$
End Function

' Outputs s$.
'
' s$ is appended to con.buf$ one character at a time. Only when we switch from
' non-spaces to spaces or vice versa do we flush the contents of con.buf$ to the
' console. As a result calling this function will probably not print the
' entirety of s$; ' the last 'word' or part thereof may be left in con.buf$.
Sub con.print(s$)
  con.count = 0

  If Len(s$) = 1 Then
    If (s$ = " ") Xor con.space Then con.flush() : con.space = (s$ = " ")
    con.buf$ = con.buf$ + s$
  Else
    Local c$, i
    For i = 1 To Len(s$)
      c$ = Mid$(s$, i, 1)
      If (c$ = " ") Xor con.space Then con.flush() : con.space = (c$ = " ")
      con.buf$ = con.buf$ + c$
    Next i
  EndIf
End Sub

' Writes con.buf$ to the console and clears it.
'
' If con.buf$ does not fit on the current line then first write CRLF and then if
' con.buf$ contains non-spaces write con.buf$ to the console.
Sub con.flush()
  If con.spin Then Print Chr$(8); " "; Chr$(8); : con.spin = 0

  Do
    If con.x = 1 And con.lines > CON.HEIGHT - 2 Then
      Print "[MORE] ";
      Do While Inkey$ <> "" : Loop
      Do While Inkey$ = "" : Loop
      Print
      con.lines = 0
    EndIf

    If con.x + Len(con.buf$) > CON.WIDTH + 1 Then
      Print
      con.lines = con.lines + 1
      con.x = 1
      If con.space Then con.buf$ = "" : Exit Sub
    Else
      Print con.buf$;
      con.x = con.x + Len(con.buf$)
      con.buf$ = ""
      Exit Sub
    EndIf
  Loop
End Sub

' Flushes con.buf$ to the console and then writes CRLF.
Sub con.endl()
  con.flush()

  If con.count < 0 Then
    Exit Sub
  ElseIf con.count >= 10 Then
    ' If the story outputs 10 or more empty lines then we assume it was trying
    ' to clear the screen
    Local i
    For i = 0 To CON.HEIGHT - con.count - 1 : Print : Next i
    con.count = -999 ' to avoid any unnecessary additional empty lines
    con.lines = 0
    Exit Sub
  EndIf

  Print
  con.count = con.count + 1
  con.lines = con.lines + 1
  con.x = 1
End Sub

Sub con.println(s$, center)

  If Len(s$) > 0 Then
    If center Then
      If con.x <> 1 Then Error "Cannot center text unless on a new line."
      If Len(s$) < CON.WIDTH Then con.print(Space$((CON.WIDTH - Len(s$)) \ 2) + s$)
    Else
      con.print(s$)
    EndIf
  EndIf

  con.endl()
End Sub

' Echos the contents of a (hopefully) text file to the console.
Sub con.print_file(f$, center)
  Local s$, w

  If center Then
    Open f$ For Input As #1
    Do
      Line Input #1, s$
      w = Max(w, Len(s$))
    Loop While Not Eof(#1)
    Close #1
  EndIf

  Open f$ For Input As #1
  Do
    Line Input #1, s$
    If center Then
      con.println(s$ + Space$(w - Len(s$)), center)
    Else
      con.println(s$)
    EndIf
  Loop While Not Eof(#1)
  Close #1
End Sub

Sub con.open_in(fd, f$)
  con.close_in()
  Open f$ For Input As #fd
  con.fd_in = fd
End Sub

Sub con.close_in()
  If con.fd_in <> 0 Then Close #con.fd_in
  con.fd_in = 0
End Sub

Sub con.open_out(fd, f$)
  con.close_out()
  Open f$ For Output As #fd
  con.fd_out = fd
End Sub

Sub con.close_out()
  If con.fd_out<> 0 Then Close #con.fd_out
  con.fd_out = 0
End Sub

Sub con.close_all()
  con.close_in()
  con.close_out()
End Sub
