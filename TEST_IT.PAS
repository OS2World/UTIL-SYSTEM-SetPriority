program test_it;

uses setprio,crt;

var
	counter:	longint;
	ch:				char;
	Class:		LongInt;
	Offset:		LongInt;

begin
	counter:=0;
	Class:=1;
	repeat
		inc(counter);
		if counter>31 then begin
			inc(Class);
			counter:=0;
		end;
		if Class>5 then Class:=1;
		asm
			mov ax, 1680h
			int 2fh
		end;
		SetPriority(Class,Counter);
		GetPriority(Class,Offset);
		write('Test ');
		write(counter);
		write(' Class= ');
		write(Class);
		write(', Offset= ');
		writeln(Offset);
	until keypressed;
	ch:=readkey;
	SetPriority(2,0);
	GetPriority(Class,Offset);
	write('Class= ');
	write(Class);
	write(', Offset= ');
	writeln(Offset);
end.