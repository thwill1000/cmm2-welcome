' Author: Thomas Hugo Williams

Option Explicit On
Option Default Integer
Option Base 1

#Include "common/welcome.inc"

we.check_firmware_version()
'we.run_program(WE.INSTALL_DIR$ + "/splash/splash2.bas")
we.run_menu()
