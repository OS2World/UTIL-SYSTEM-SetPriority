UNIT SetPrio;

Interface

Procedure SetPriority(Class:LongInt;Delta:LongInt);

Procedure GetPriority(var Class:LongInt; var Delta:LongInt);

Implementation

Procedure SetPriority(Class:LongInt;Delta:LongInt);external;
Procedure GetPriority(var Class:LongInt; var Delta:LongInt);external;
{$L PRIOINT.OBJ}


end.