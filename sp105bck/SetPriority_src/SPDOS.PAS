{***************************************************************************}
Program SPDOS;
{---------------------------------------------------------------------------}
{Dieses Programm geh”rt zum SetPriority-Paket und startet das als Parameter }
{bergebene Programm mit der bergebenen Priorit„t.                         }
{---------------------------------------------------------------------------}

Uses
	dos,
	Setprio;

Type
	PriorityClassRec=Record
		Name:String[1];
		Wert:longint;
	end;

Const
	PrioArray:array[0..4] of PriorityClassRec=(
		(Name:'n';Wert:0),
		(Name:'i';Wert:1),
		(Name:'r';Wert:2),
		(Name:'t';Wert:3),
		(Name:'f';Wert:4));

var
	ParseClass	:string[1];
	PrioClass		:longint;
	ParseDelta	:string;
	DeltaClass	:longint;
	i						:integer;
	Params			:string;
	ClientExit	:word;

begin
	if ParamCount>1 then begin
		ParseClass:=copy(ParamStr(1),1,1);{Klasse ermitteln                     }
		i:=0;
		while (ParseClass<>PrioArray[i].Name) AND (i<5) do inc(i);
		PrioClass:=PrioArray[i].Wert;
		ParseDelta:=copy(ParamStr(1),2,length(Paramstr(1))-1);
		if ParseDelta='' then ParseDelta:='0';
		val(ParseDelta,DeltaClass,i);
		if i=0 then begin
			Params:='';
			i:=3;
			while i<=ParamCount do begin
				Params:=concat(Params,Paramstr(i),' ');
				inc(i);
			end;
			setpriority(PrioClass,DeltaClass);
			exec(Paramstr(2),Params);
			if DosError<>0 then begin
				case DosError of
					2:	begin
								writeln('SP: SPDOS: File not found.');
							end;
					3:	begin
								writeln('SP: SPDOS: Path not found.');
							end;
					5:	begin
								writeln('SP: SPDOS: Access to file denied.');
							end;
					6:	begin
								writeln('SP: SPDOS: Invalid Handle.');
							end;
					8:	begin
								writeln('SP: SPDOS: Insufficient DOS Memory.');
							end;
					10:	begin
								writeln('SP: SPDOS: Invalid Environment.');
							end;
					11:	begin
								writeln('SP: SPDOS: Invalid Format.');
							end;
					12:	begin
								writeln('SP: SPDOS: No further Files available.');
							end;
				else 	begin
								writeln('SP: SPDOS: Unknown DOS error.');
							end;
				end;
				Halt(DosError);
			end else begin
				ClientExit:=DosExitCode;
				writeln('SP: SPDOS: '+ParamStr(2)+' returned ',ClientExit);
				Halt(ClientExit);
			end;
		end else begin
			writeln('SP: SPDOS: Wrong priority delta.');
		end;
	end else begin
		writeln('SP: SPDOS: Not enough parameters.');
		writeln;
		writeln('SPDOS Version 1.04 (04-26-96) (c) Jens Glathe');
		writeln;
		writeln('SPDOS is a program which sets the priority of a DOS session');
		writeln('at OS/2 machines (version 2.0 or higher). The "vdosprio.sys"');
		writeln('virtual device driver must have been loaded to work with this');
		writeln('program.');
		writeln;
		writeln('Usage: SPDOS <class>[delta] <program_to_start> [options]');
		writeln;
		writeln('The program to be started must be an executable file and named');
		writeln('with the full path. If you want to run batch files, use:');
		writeln;
		writeln('SPDOS <class>[delta] <path>\command.com /c <batchfile> [options]');
		writeln;
		writeln('Valid classes are:');
		writeln('                   i:  idle');
		writeln('                   r:  regular');
		writeln('                   t:  time-critical (DANGEROUS!!)');
		writeln('                   f:  foreground server');
		writeln('                   n:  no change');
		writeln;
		writeln('The delta is an absolute offset in the class and in the range from 0 to 31.');
	end;
end.