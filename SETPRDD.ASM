; Treiber zum Setzen der PrioritÑt einer DOS-Sitzung.
;	Und seit neuestem: PM-Interface fÅr genau dieses, und zusÑtzlich die Mîg-
;	lichkeit, andere Einstellungen der DOS-Sitzung (wie z.B. IDLE_SENSITIVITY)
; zu Ñndern.
;	(C) Jens Glathe
;	letzte énderung: 15.5.1995
; vor jedem SHL ein CLC eingefÅgt (zur Sicherheit, wird aber nicht benîtigt)

; Aufrufe: Int 45h

;	SetPriority:
;	EAX: Class	(0..5)
;	EDX: Offset	(0..31)

;	IdleCall:
; EAX=1680h

;	GetPriority:
;	EAX=42h
; RÅckgabewert:
;	EAX: Class	(0..5)
;	EDX: Offset (0..31)


.386p																;Privilegierte Befehle zulassen, ist zum
																		;linken aber nicht unbedingt erforderlich.
	MODEL FLAT

	include setprdd.inc

	ASSUME	CS:FLAT, DS:FLAT, SS:FLAT, ES:FLAT

	PUBLIC  _VDDINIT

_DATA	SEGMENT	DWORD USE32 PUBLIC 'DATA'	;Instanz-Datenfeld

this_VDM	DD 0H
this_CLASS DD 2H															  ;aktuelle Klasse
idlecall_old_class DD 0H                        ;aktueller Offset der jeweiligen
																								;Klasse
idlecall_old_offset DD 0H
offset_nochange DD 0H														;hiermit kînnen witzige Effekte
																								;auftreten. Sie werden nicht
																								;abgefangen.
offset_idle_class DD 0H
offset_regular_class DD 0H
offset_tc_class DD 0H
offset_fg_class DD 0H
offset_si_class DD 0H
_DATA	ENDS

INIT_CODE	SEGMENT DWORD USE32 PUBLIC 'CODE'

	ALIGN 04H
_VDDINIT	PROC NEAR
	PUSH	EBP
	MOV	EBP,ESP

	PUSH VDM_CREATE
	PUSH OFFSET FLAT: SetPrioCreate
	CALL	VDHINSTALLUSERHOOK
	OR	EAX,EAX												  ;Vergleich auf Null (clever)
	JNE	INIT_REGISTEROFFSET							;Create Hook erfolgreich, weiter

INIT_FAILURE:
	ALIGN 04h
	XOR	EAX,EAX                         ;nicht erfolgreich, Abbruch
	LEAVE
	RET
; Auskommentiert 2.3.1998, da Konflikt mit SESSION_PRIORITY von anderem Treiber
;INIT_CHECKOSVERSION:									;Ab OS/2 3.0 (20.30) wird SESSION_PRIORITY
;																			;nicht registriert, da es diese schon gibt.
;	ALIGN 04h
;	PUSH 0h
;	PUSH VDHGSV_VERMAJOR
;	CALL VDHQUERYSYSVALUE
;	CMP EAX, OSMajor
;	JB INIT_REGISTEROFFSET

;	PUSH 0h
;	PUSH VDHGSV_VERMINOR
;	CALL VDHQUERYSYSVALUE
;	CMP EAX, OSMinor
;	JNB INIT_REGISTERCLASS

INIT_REGISTEROFFSET:									;falls es OS/2 2.x ist, SESSION_PRIORITY
																			;registrieren
	ALIGN 04h
	PUSH OFFSET FLAT:OffsetPropertyName
	PUSH 0h
	PUSH 0h
	PUSH VDMP_INT
	PUSH VDMP_ORD_OTHER
	PUSH VDMP_CREATE										;wird sich irgendwann auf 0h (immer) Ñndern
	PUSH 01h                            ;Standardwert ist "1"
	PUSH OFFSET FLAT:OffsetBounds
	PUSH OFFSET FLAT:OffsetValidateSet
	CALL VDHREGISTERPROPERTY
	OR EAX,EAX
	JZ INIT_FAILURE

INIT_REGISTERCLASS:										;Die Einstellung PRIORITY_CLASS registrie-
																			;ren
	ALIGN 04h
	PUSH OFFSET FLAT:ClassPropertyName
	PUSH 0h
	PUSH 0h
	PUSH VDMP_INT
	PUSH VDMP_ORD_OTHER
	PUSH VDMP_CREATE										;wird sich irgendwann auf 0h (immer) Ñndern
	PUSH 02h                            ;Standardwert ist "Regular"
	PUSH OFFSET FLAT:ClassBounds
	PUSH OFFSET FLAT:ClassValidateSet
	CALL VDHREGISTERPROPERTY
	OR EAX,EAX
	JZ INIT_FAILURE

	PUSH OFFSET FLAT:PriorityAPIName
	PUSH 0h
	PUSH 0h
	PUSH VDMP_BOOL
	PUSH VDMP_ORD_OTHER
	PUSH VDMP_CREATE
	PUSH 1h                            	;Standardwert ist ON.
	PUSH 0h
	PUSH 0h
	CALL VDHREGISTERPROPERTY
	OR EAX,EAX
	JZ INIT_FAILURE

INIT_SUCCESS:
	ALIGN 04h
	MOV	EAX,01H                         ;Create Hook erfolgreich, weiter
	LEAVE
	RET
_VDDINIT	ENDP
INIT_CODE	ENDS

; Initialisierungsroutinen

_TEXT	SEGMENT DWORD USE32 PUBLIC 'CODE'

;ja,ja, es ist nicht schîn, Konstanten einfach ins Codesegment zu schreiben.
;Aber effektiv.

ClassPropertyName DB 'SESSION_PRIORITY_CLASS',0h
OffsetPropertyName DB 'SESSION_PRIORITY_OFFSET',0h
PriorityAPIName DB 'SESSION_PRIORITY_API',0h	;API des Treibers zuschaltbar :)
ClassBounds VPBOUND <1,5,1>
OffsetBounds VPBOUND <1,32,1>

ALIGN 04h
ClassValidateSet PROC NEAR
;zur Zeit ist das eher eine Dummy-Funktion. :)
	PUSH	EBP
	MOV	EBP,ESP

CVS_NIX_ZU_TUN:
	ALIGN 04h
	XOR EAX,EAX
	LEAVE
	RET 16
ClassValidateSet ENDP

ALIGN 04h
OffsetValidateSet PROC NEAR
;zur Zeit ist das eher eine Dummy-Funktion. :)
	PUSH	EBP
	MOV	EBP,ESP

OVS_NIX_ZU_TUN:
	ALIGN 04h
	XOR EAX,EAX
	LEAVE
	RET 16
OffsetValidateSet ENDP

	ALIGN 04H

	PUBLIC SetPrioCreate

SetPrioCreate	PROC NEAR
	PUSH	EBP
	MOV	EBP,ESP

	MOV	EAX,[EBP+08H];	hvdm
	MOV	DWORD PTR  this_VDM,EAX

	;hier wird erstmal bestimmt, ob die Treiber-API Åberhaupt verfÅgbar sein soll.
	PUSH OFFSET FLAT:PriorityAPIName
	CALL VDHQUERYPROPERTY
	OR EAX,EAX
	JZ CREATE_QUERYPRIORITIES

	PUSH 0h															;VDHINSTALLINTHOOK aufrufen
	PUSH IntVector
	PUSH OFFSET FLAT:PrioIntHook
	PUSH VDH_ASM_HOOK
	CALL VDHINSTALLINTHOOK

CREATE_QUERYPRIORITIES:
	ALIGN 04h														;den in der DOS-Sitzung eingestellten Off-
																			;set fÅr die PrioritÑt abfragen
	PUSH OFFSET FLAT:OffsetPropertyName
	CALL VDHQUERYPROPERTY
	SUB EAX, 01h
	MOV EDX, EAX                        ;Offset nach EDX
	PUSH OFFSET FLAT:ClassPropertyName
	CALL VDHQUERYPROPERTY								;Class in EAX
	CALL SetPriority										;und PrioritÑt setzen :)

CREATE_EXIT:
	ALIGN 04h
	MOV	EAX,01H
	LEAVE
	RET 4
SetPrioCreate	ENDP

;PrioIntHook Function
	ALIGN 04H

	PUBLIC PrioIntHook

PrioIntHook PROC NEAR
	PUSH  EBP
	MOV	EBP,ESP

	MOV EDX,DWORD PTR [EBX+14h]
	MOV EAX,DWORD PTR [EBX+1Ch]
	AND EAX,0000FFFFh
	AND EDX,0000FFFFh
	OR  EAX,EAX													;Funktionswert ungleich null?
	JNZ IDLE_TEST
	XOR EAX,EAX                         ;nein, Fehler
	JMP Ende

IDLE_TEST:
	ALIGN 04h
	CMP EAX,FuncValue                   ;erstmal schaun, ob das ein IdleCall war
	JNE TEST_GETPRIORITY

	MOV EAX,this_CLASS									;IDLECALL: auf auf, sichern
	MOV idlecall_old_class,EAX
	CLC
	SHL EAX, 2h
	MOV ECX, OFFSET FLAT:offset_nochange
	ADD EAX, ECX
	MOV ECX, [EAX]
	MOV idlecall_old_offset, ECX

	MOV EAX, 2h
	XOR EDX, EDX												;StandardprioritÑt setzen
	CALL SetPriority

	PUSH 0                              ;Versuch, Zeitscheibe los zu werden
	CALL VDHYIELD

	MOV EAX,idlecall_old_class					; Alte PrioritÑt setzen
	MOV EDX,idlecall_old_offset
	JMP Alles_OK

TEST_GETPRIORITY:
	ALIGN 04h
	CMP EAX,GetPriority									;auf GetPriority-Aufruf prÅfen
	JNE SETPRIORITY_NORMAL

	MOV EAX, this_CLASS
	MOV DWORD PTR [EBX+1Ch], EAX				;aktuelle Klasse auslesen
																			;korrspondierenden Offset holen
	CLC
	SHL EAX, 2h													;Multiplikation von Class mit 4
	MOV ECX, OFFSET FLAT:offset_nochange;Anfansadresse der Offset-Struktur holen
	ADD EAX, ECX                        ;Strukturoffset errechnen
	MOV EDX, [EAX]
	MOV DWORD PTR [EBX+14h], EDX      	;und auslesen

	CLC																	;das war's
	CMC
	LEAVE
	RET

SETPRIORITY_NORMAL:
	ALIGN 04h
	CMP EAX, 05h												; obere Grenze der Klassen abprÅfen
	JNG Delta_Obergrenze
	XOR EAX,EAX
	JMP Ende

Delta_Obergrenze:                    	; hier reicht es, die Obergrenze zu
	ALIGN 04h														; prÅfen, da negative Zahlen durch das
	CMP EDX,1Fh                         ; AND EDX, 0000FFFFh ausgeschlossen sind.
	JNG Alles_OK
	XOR EAX,EAX
	JMP Ende

Alles_OK:
	ALIGN 04h
	CALL SetPriority

	MOV EAX, 1h													;alles OK

Ende:

	Align 04h

	MOV DWORD PTR [EBX+1Ch],EAX					;EAX zurÅckschreiben in den Task-Kontext

	CLC
	CMC
	LEAVE
	RET
PrioIntHook ENDP

	ALIGN 04H
SetPriority PROC NEAR
;Parameter: in EAX Class, in EDX Delta

	PUSH  EBP
	MOV	EBP,ESP

	MOV this_CLASS, EAX                 ;neue Klasse merken

	PUSH EAX														;EAX sichern
	CLC
	SHL EAX, 2h													;Multiplikation mit 4
	MOV ECX, OFFSET FLAT:offset_nochange;Anfangsadresse der Struktur holen
	ADD EAX, ECX                        ;Strukturoffset errechnen
	MOV ECX, [EAX]
	MOV DWORD PTR [EAX], EDX						;alten Offset sichern
	SUB EDX, ECX                        ;differentiellen Offset errechnen
	POP EAX

	PUSH this_VDM                       ;und setzen
	PUSH EAX
	PUSH EDX
	CALL VDHSETPRIORITY

	LEAVE
	RET
SetPriority ENDP

_TEXT	ENDS

END _VDDINIT
