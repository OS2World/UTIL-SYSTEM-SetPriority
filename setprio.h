/* Das ist der Aufruf zum Setzen der Priorit„t. Zu diesem Zweck muá der Trei-*/
/* ber "vdosprio.sys" beim Booten des Systems geladen worden sein (in CONFIG */
/* .SYS: DEVICE=<Pfad>VDOSPRIO.SYS) Der Priorit„tsmechanismus von OS/2 unter-*/
/* scheidet mehrere Klassen, und in diesen Klassen wiederum Stufen. Klasse  */
/* und Stufe mssen beim Aufruf bergeben werden. Folgende Werte sind hier */
/* erlaubt:                                                                */

/* Class:
		1		Idle (geringste Priorit„t)
		2		Regul„r (Standard)
		3		Zeitkritisch	(h”chste Priorit„t, sehr gef„hrlich!!)
		4		Server (Vordergrund, kommt nach Regul„r)
		5		Simulierter Interrupt (???)
		1680h		versuche, einen Taskwechsel auszufhren (Bugfix)

		Andere Werte sind nicht definiert.

		Delta:
		0..31 Abstufungen in einer Klasse (0 kleinste, 31 h”chste Priorit„t)

		Normalerweise werden DOS-Sitzungen mit Klasse 2 und Delta 0 gestartet.

		Vorsicht!! Wenn das Programm auf erh”hter Priorit„t l„uft und st„ndig
		Zeit verbraucht, dann kommen andere Programme nicht mehr (oder nur sel-
		ten) ran!!                                                             */

extern BOOL Far Pascal SetPriority(unsigned long Class, unsigned long Delta);
extern void Far Pascal GetPriority((unsigned long)* Class, (unsigned long) * Delta);

/* CAUTION: this header file hasn't been tested yet (never had the need to write
DOS programs in C :-)), so there could be errors. Please refer to prioint.asm
for the actions taken to communicate with VDOSPRIO.SYS.                      */
