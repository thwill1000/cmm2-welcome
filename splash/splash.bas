' Author: Thomas Hugo Williams

Option Explicit
Option Default Integer
Option Base 1

#Include "../common/common.inc"

Mode 1
Cls

Print
Print
Print "   _____         _                      ___  ___              _             _  _           _____ "
Print "  /  __ \       | |                     |  \/  |             (_)           (_)| |         / __  \"
Print "  | /  \/  ___  | |  ___   _   _  _ __  | .  . |  __ _ __  __ _  _ __ ___   _ | |_   ___  `' / /'"
Print "  | |     / _ \ | | / _ \ | | | || '__| | |\/| | / _` |\ \/ /| || '_ ` _ \ | || __| / _ \   / /  "
Print "  | \__/\| (_) || || (_) || |_| || |    | |  | || (_| | >  < | || | | | | || || |_ |  __/ ./ /___"
Print "   \____/ \___/ |_| \___/  \__,_||_|    \_|  |_/ \__,_|/_/\_\|_||_| |_| |_||_| \__| \___| \_____/"
Print
Print
Print "           _    _        _                                 _____                                 "
Print "          | |  | |      | |                               |_   _|                                "
Print "          | |  | |  ___ | |  ___   ___   _ __ ___    ___    | |    __ _  _ __    ___             "
Print "          | |/\| | / _ \| | / __| / _ \ | '_ ` _ \  / _ \   | |   / _` || '_ \  / _ \            "
Print "          \  /\  /|  __/| || (__ | (_) || | | | | ||  __/   | |  | (_| || |_) ||  __/            "
Print "           \/  \/  \___||_| \___| \___/ |_| |_| |_| \___|   \_/   \__,_|| .__/  \___|            "
Print "                                                                        | |                      "
Print "                                                                        |_|                      "
Print Space$(41) + WE.VERSION$
Print
Print
Print "             <Imagine this is an impressive 15 second demo of sound and graphics>"
Print
Print
Print "                                    Press any key to skip"
Print
Print

' Clear the keyboard input buffer
Do While Inkey$ <> "" : Loop

Dim i, j
For i = 1 To 16
  If i <> 1 Then Print Chr$(13);
  Print "                                Menu displayed in " Format$(16 - i, "%2g") " seconds ";
  For j = 1 To 100
    Pause 10
    If Inkey$ <> "" Then i = 17 : j = 101
  Next j
Next i

we.run_menu()

End
