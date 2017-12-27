/* SetPriority (SP)                                                        */
/* Angepa·t an OS/2 Version 2.x von Jens Glathe, 3.9.1993                  */
/* Erweiterung fÅr das Beeinflussen von DOS-Boxen: 6.9.1993,16/17.9.1993   */
/* letzte énderung: Jens Glathe 15.05.1994                                 */

#define INCL_DOSSESMGR
#define INCL_DOSPROCESS
#define INCL_NOPM

#include <os2.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#define PATHLEN 256

static struct _pt											/*Structure for Class info           */
{
  char ch;
  USHORT usClass;
} pt[]=
{
  {'i', PRTYC_IDLETIME},
  {'n', PRTYC_NOCHANGE},
  {'r', PRTYC_REGULAR},
  {'t', PRTYC_TIMECRITICAL},
  {'f', PRTYC_FOREGROUNDSERVER},
  {0,   0}
};

static struct _st                     /*Structure for Session type         */
{
	char ch;
	USHORT Class;
} st[]=
{
	{'o', SSF_TYPE_WINDOWABLEVIO},
	{'D', SSF_TYPE_VDM},
	{'d', SSF_TYPE_WINDOWEDVDM},
	{0, SSF_TYPE_DEFAULT}
};

char *prior[]={"no change in", "idle", "regular", "time critical", "foreground"};

char		args[255];
ULONG		usClass=PRTYC_NOCHANGE;
ULONG		rc;
LONG		sDelta=0;
struct	_pt *ppt;
char		**p;
struct  _st *pst;
ULONG 	ulSitzungsTyp=SSF_TYPE_DEFAULT;

PPIB		myPIB;
PTIB		myTIB;

int main(int argc, char *argv[])
{
  if (argc < 3)
  {
		printf("\nSetPriority Version 1.02 (c) 1993, 1994 Jens Glathe, Scott Dudley\n\n");

    printf("Usage:\n\n");

		printf("SP <class>[delta] <sessiontype> <program> [args...]\n\n");

    printf("<class>:  n=no change, i=idle, r=regular, f=foreground, t=time critical\n");
		printf("[delta]:  Any number from -31 to 31, 0 to 31 for DOS sessions\n");
		printf("<sessiontype>:  o=OS/2 Window or PM App, d=DOS-Window, D=DOS-Fullscreen\n");
		printf("\nThe driver \"VDOSPRIO.SYS\" must have been loaded to change the priority\n");
		printf("of a DOS session.\n");
		return 1;
	}

	*argv[1]=(char)tolower(*argv[1]);

	for (ppt=pt; ppt->ch; ppt++)        /* PrioritÑtsklasse bestimmen        */
		if (ppt->ch==*argv[1])
		{
			usClass=ppt->usClass;
			break;
		}

	for (pst=st; pst->ch; pst++)        /* Sitzungstyp bestimmen             */
		if (pst->ch==*argv[2])
		{
			ulSitzungsTyp=pst->Class;
			break;
    }

	sDelta=atoi(argv[1] + !!islower(*argv[1])); /* VERY dirty trick !!       */
	/* Durch die Verneinung "nicht nicht" steht als Ergebnis eine 1, was     */
	/* sonst nicht unbedngt der Fall ist.                                    */

	*args='\0';

	printf("SP: running %s, %s priority, delta %d\n",
				 argv[3], prior[usClass], sDelta);

	if (ulSitzungsTyp!=SSF_TYPE_WINDOWABLEVIO){

		strcat(args,"SPDOS.EXE ");
		strcat(args,*(argv+1));
		strcat(args," ");

		for (p=argv+3; *p; p++)						/* Argumenteliste zusammenstellen    */
		{
			strcat(args, *p);
			strcat(args, " ");
		}
		system(args);

	} else{
		for (p=argv+3; *p; p++)						/* Argumenteliste zusammenstellen    */
		{
			strcat(args, *p);
			strcat(args, " ");
		}

		if (rc=DosGetInfoBlocks(&myTIB,&myPIB))
			{printf("SP: DosGetInfoBlocks() rc=%ld",rc);
			}

		if ((rc=DosSetPriority(
				PRTYS_PROCESSTREE,
				usClass,
				sDelta,
				myPIB->pib_ulpid)) != 0)
			printf("DosSetPriority() rc=%u\n", rc);

		system(args);
	}
	return rc;
}
