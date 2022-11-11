/**
    @name: ChessBoard
    @description:

    @author: Zai Dium
    @update: 2022-02-16
    @revision: 105
    @localfile: ?defaultpath\chess\?@name.lsl
    @license: MIT

    @ref:

    @notice:

/** Static Variables **/

list pieces = [
    "King",
    "Queen",
    "Bishop",
    "Knight",
    "Rook",
    "Pawn"
];

list p = [
    "k",
    "q",
    "b",
    "k",
    "r",
    "p"
];

list initBoard = [
"r", "n", "b", "q", "k", "b", "n", "r",
"p", "p", "p", "p", "p", "p", "p", "p",
"", "", "", "", "", "", "", "",
"", "", "", "", "", "", "", "",
"", "", "", "", "", "", "", "",
"", "", "", "", "", "", "", "",
"p", "p", "p", "p", "p", "p", "p", "p",
"r", "n", "b", "q", "k", "b", "n", "r"
];

list board;

vector unit;
vector size;

integer active_link;

//* case sensitive

integer getLinkNumber(string name)
{
    integer c = llGetNumberOfPrims();
    integer i = 1; //based on 1
    while(i <= c)
    {
        if (llGetLinkName(i) == name) // llGetLinkName based on 1
            return i;
        i++;
    }
    llOwnerSay("Could not find " + name);
    return -1;
}

key getLinkKey(string name) {
	integer index = getLinkNumber(name);
    if (index>0)
	    return llGetLinkKey(index);
    else
    	return NULL_KEY;
}

setPos(string name, float x, float y){
    integer index = getLinkNumber(name);
    if (index>0) {
        list values = llGetLinkPrimitiveParams(LINK_ROOT, [PRIM_POS_LOCAL]);
        vector pos = llList2Vector(values, 0);
        //llOwnerSay((string)pos);
		pos = <x, y, size.z / 2 + 0.0001>;
        llOwnerSay("new pos "+ (string)pos);
        llSetLinkPrimitiveParams(index, [PRIM_POSITION, pos]);
    }
}

//*
setPlace(string name, float x, float y){
    x = x * unit.x - size.x / 2 + unit.x / 2;
    y = y * unit.y - size.y / 2 + unit.y / 2;
    llOwnerSay((string)x);
    setPos(name, x, y);
}

default
{
    state_entry()
    {
        board = initBoard;
        list values = llGetLinkPrimitiveParams(LINK_THIS, [PRIM_SIZE]);
		size = llList2Vector(values, 0);
        //llOwnerSay("size "+(string)size);
        unit.x = size.x / 8;
        unit.y = size.y / 8;
        //llOwnerSay("unit: "+(string)unit);
        setPlace("active", 3, 3);
    }
}
