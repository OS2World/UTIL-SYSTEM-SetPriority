;Include fr VDOSPRIO.sys

IDEAL

EXTRN	VDHINSTALLUSERHOOK  :NEAR
EXTRN	VDHSETPRIORITY			:NEAR
EXTRN VDHINSTALLINTHOOK		:NEAR
EXTRN VDHYIELD						:NEAR
EXTRN VDHDEVBEEP					:NEAR
EXTRN VDHQUERYPROPERTY		:NEAR
EXTRN VDHREGISTERPROPERTY	:NEAR
EXTRN VDHQUERYSYSVALUE		:NEAR

VDM_CREATE EQU 0											;VDM wird erzeugt
VDM_TERMINATE EQU 1										;VDM wird beendet
VDH_ASM_HOOK EQU 1										;ASM-Hook
VDH_YIELD_TIME_CRITICAL EQU 1					;Nur bei Zeitkritischen Tasks CPU hergeben

IntVector EQU 45h											;Int, der benutzt wird
FuncValue EQU 00001680H  							;Registerwert fr IdleCall
GetPriority	EQU 00000042H             ;RegisterWert fr GetPriority
OSMajor EQU 020												;Versionsnummer, ab der nicht mehr ver-
																			;sucht wird, SESSION_PRIORITY zu instal-
																			;lieren.
OSMinor EQU 030

ERROR_INVALID_DATA	EQU	13       			;Fehlercode

TYPEDEF USHORT WORD
TYPEDEF ULONG DWORD

;***    VPTYPE: VDM Property Types
;
;
VDMP_BOOL       EQU     0   ;boolean
VDMP_INT        EQU     1   ;integer - ULONG size, but only USHORT is valid
VDMP_ENUM       EQU     2   ;enumeration
VDMP_STRING     EQU     3   ;asciiz string
VDMP_MLSTR      EQU     4   ;multi-line string, separated by linefeed (00ah)

TYPEDEF VPTYPE USHORT       ;property type



;***    VPORD: VDM Property Ordinals
;
;
VDMP_ORD_OTHER  EQU     0   ;custom VDD property
VDMP_ORD_KERNEL         EQU     1   ;asciiz path of DOS kernel
VDMP_ORD_SHELL  EQU     2   ;asciiz path of DOS shell
VDMP_ORD_RMSIZE         EQU     3   ;integer size of DOS box (128K..640K)
VDMP_ORD_FCB    EQU     4   ;integer total FCBs
VDMP_ORD_FCB2   EQU     5   ;integer FCBs immune to close LRUing
VDMP_ORD_BREAK  EQU     6   ;boolean BREAK flag
VDMP_ORD_DOSDD  EQU     7   ;mlstr DOS device drivers
VDMP_ORD_VMBOOT         EQU     8   ;mlstr virtual machine boot drive(s)
;VDMP_ORD_IOPL3         EQU     9   ; boolean IOPL3 flag              // 6.10
VDMP_ORD_VERSION        EQU     10  ;mlstr fake version entries
VDMP_ORD_DOS_UMB        EQU     11  ;boolean flag - DOS owns UBMs
VDMP_ORD_DOS_HIGH       EQU     12  ;boolean flag - DOS loaded high
VDMP_ORD_LASTDRIVE      EQU     13  ;asciiz lastdrive
VDMP_ORD_FILES  EQU     14  ;integer total FILES


TYPEDEF VPORD USHORT        ;property ordinal



;***    VDHRegisterProperty Flags
;
;
VDMP_CREATE     EQU     000000001h  ;create-time only property
VDMP_ADVANCED   EQU     000000002h  ;advanced property (not shown by default)



;***    VDHRegisterProperty PFNVDHRP ordinals
;
;
VDHPROP_VALIDATE        EQU     000000000h ;validate parameter
VDHPROP_SET     EQU     000000001h ;set parameter



;***    VPBOUND - limits for VDMP_INT properties
;
;   Notes:  (1) max > min must hold
;           (2) (max-min) must be a multiple of step
;           (3) step = 1 implies that all values between min and max are valid
;

STRUC VPBOUND                     ;vpb
		min DW ?   ;minimum allowed value
		max DW ?   ;maximum allowed value
		step DW ?  ;increment between values
ENDS VPBOUND
TYPEDEF PVPBOUND DWORD                     ;pvpb

;***    VDHQuerySysValue ordinals

; Global Values          Ordinal      Type   Units      Range

VDHGSV_DAY      EQU     0   ;ULONG  days       1 <= x <= 31
VDHGSV_MONTH    EQU     1   ;ULONG  months     1 <= x <= 12
VDHGSV_YEAR     EQU     2   ;ULONG  years   1980 <= x <= MAXULONG
VDHGSV_DAYOFWEEK        EQU     3   ;ULONG  days       0 <= x <= 6
VDHGSV_HOUR     EQU     4   ;ULONG  hours      0 <= x <  24
VDHGSV_MINUTE   EQU     5   ;ULONG  minutes    0 <= x <  60
VDHGSV_SECOND   EQU     6   ;ULONG  secs       0 <= x <  60
VDHGSV_HUNDREDTH        EQU     7   ;ULONG  1/100s     0 <= x <  100
VDHGSV_SECONDS1970      EQU     8   ;ULONG  secs       0 <= x <= MAXULONG
VDHGSV_TIMEZONE         EQU     9   ;ULONG  minutes    0 <= x <= MAXULONG
VDHGSV_MSECSBOOT        EQU     10   ;ULONG  ms         0 <= x <= MAXULONG
VDHGSV_TIMERINTERVAL    EQU     11   ;ULONG  ms         0 <= x <= 1000
VDHGSV_DYNVARIATION     EQU     12   ;BOOL              TRUE/FALSE
VDHGSV_MAXWAIT  EQU     13   ;ULONG  secs       0 <= x <= MAXULONG
VDHGSV_MINTIMESLICE     EQU     14   ;ULONG  ms         0 <= x <= MAXULONG
VDHGSV_MAXTIMESLICE     EQU     15   ;ULONG  ms         0 <= x <= MAXULONG
VDHGSV_YIELD    EQU     16   ;BOOL              TRUE/FALSE
VDHGSV_TCYIELD  EQU     17   ;BOOL              TRUE/FALSE
VDHGSV_VERMAJOR         EQU     18   ;ULONG             0 <= x <= MAXULONG
VDHGSV_VERMINOR         EQU     19   ;ULONG             0 <= x <= MAXULONG
VDHGSV_VERREVISION      EQU     20   ;CHAR              A <= x <= Z
VDHGSV_MACHINETYPE      EQU     21   ;ULONG             MACHINE_TYPE_*
VDHGSV_BLACKHOLEADDR    EQU     22   ;PVOID  bytes      0 <= x <= MAXULONG
VDHGSV_BLACKHOLESIZE    EQU     23   ;ULONG  bytes      0 <= x <= MAXULONG
VDHGSV_FGNDSESSIONID    EQU     24   ;ULONG             0 <= x <  MAXSESSIONS
VDHGSV_MAXFPSESSIONS    EQU     25   ;ULONG            ;TO BE DELETED
VDHGSV_MAXWPSESSIONS    EQU     26   ;ULONG            ;TO BE DELETED
VDHGSV_MAXPMSESSIONS    EQU     27   ;ULONG            ;TO BE DELETED
VDHGSV_RESERVESESSIONS  EQU     28   ;Reserved         ;TO BE DELETED
VDHGSV_ARPLADDR         EQU     29   ;ULONG
VDHGSV_MACHINEINFO      EQU     30   ;ULONG ptr to System Configuration Table
VDHGSV_PPOSREGS         EQU     31   ;ULONG pointer to POS Regs structure
VDHGSV_PICMASK  EQU     32   ;ULONG original PIC mask values   6.13
VDHGSV_IRETADDR         EQU     33   ;ULONG address of IRET in ROM
; if you add a new entry, please update GSVMAX in src\dos\mvdm\vdmvdh.inc

; Local Values           Ordinal      Type   Units      Range

VDHLSV_HVDM     EQU     4096   ;HVDM
VDHLSV_PID      EQU     4097   ;PID
VDHLSV_PCRF     EQU     4098   ;PCRF
VDHLSV_SESSIONID        EQU     4099   ;ULONG             N <= x <  MAXSESSIONS
VDHLSV_FOREGROUND       EQU     4100   ;BOOL              TRUE/FALSE
VDHLSV_RMSIZE   EQU     4101   ;ULONG  kbytes     0 <  x <= 640
VDHLSV_CODEPAGEID       EQU     4102   ;ULONG             See DosGetCP
VDHLSV_PRIORITYCLASS    EQU     4103   ;ULONG             See VDHSetPriority
VDHLSV_PRIORITYLEVEL    EQU     4104   ;ULONG             See VDHSetPriority
VDHLSV_VPICBASE         EQU     4105   ;UCHAR[4]

MASM

