;Include fÅr VDOSPRIO.sys
EXTRN	VDHINSTALLUSERHOOK  :NEAR
EXTRN	VDHSETPRIORITY			:NEAR
EXTRN VDHINSTALLINTHOOK		:NEAR
EXTRN VDHYIELD						:NEAR
;EXTRN VDHDEVBEEP					:NEAR


VDM_CREATE EQU 0											;VDM wird erzeugt
VDM_TERMINATE EQU 1										;VDM wird beendet
VDH_ASM_HOOK EQU 1										;ASM-Hook
VDH_YIELD_TIME_CRITICAL EQU 1					;Nur bei Zeitkritischen Tasks CPU hergeben

IntVector EQU 45h											;Int, der benutzt wird
FuncValue EQU 00001680H
