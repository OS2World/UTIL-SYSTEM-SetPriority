UNIT SetPrio;

Interface

Procedure SetPriority(Class:LongInt;Delta:LongInt);

Implementation

Procedure SetPriority(Class:LongInt;Delta:LongInt);external;
{$L PRIOINT.OBJ}

end.