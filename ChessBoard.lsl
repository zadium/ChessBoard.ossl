/**
    @name: ChessBoard
    @description:

    @author: Zai Dium
    @update: 2022-02-16
    @revision: 140
    @localfile: ?defaultpath\Chess\?@name.lsl
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
"P", "P", "P", "P", "P", "P", "P", "P",
"R", "N", "B", "Q", "K", "B", "N", "R"
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
        pos = <x, y, size.z / 2 + 0.0001>;
        llSetLinkPrimitiveParams(index, [PRIM_POSITION, pos]);
    }
}

//*
setPlace(string name, float x, float y){
    x = x * unit.x - size.x / 2 + unit.x / 2;
    y = y * unit.y - size.y / 2 + unit.y / 2;
    setPos(name, x, y);
}

list chars = ["a", "b", "c", "d", "e", "f", "g", "h"];
list numbers = ["1", "2", "3", "4", "5", "6", "7", "8"];

integer indexOfChar(string s, integer index)
{
	return llListFindList(chars, [llGetSubString(s, index, index)]);
/*  llOrd not exists yet in some servers
	s = llToLower(s);
	integer i = (llOrd(s, index) - llOrd("a", 0));
    if ((i>=0) && (i<=7))
    	return i;
    else
    	return -1;
*/
}

integer indexOfNumber(string s, integer index)
{
	return llListFindList(numbers, [llGetSubString(s, index, index)]);
}

highlight(integer x1, integer y1, integer x2, integer y2)
{
	setPlace("ActiveFrom", x1, y1);
    setPlace("ActiveTo", x2, y2);
}

integer try_move(string msg) {
	integer c = llStringLength(msg);
	if ((c == 4) || ((c == 5) && (llGetSubString(msg, 2, 2) == " ")))
    {
    	integer i = 0;
        integer x1 = indexOfChar(msg, i);
        i++;
        integer y1 = indexOfNumber(msg, i);
        if (c == 5)
        	i++;
        i++;
        integer x2 = indexOfChar(msg, i);
        i++;
        integer y2 = indexOfNumber(msg, i);
        if ((x1>=0) && (y1>=0) && (x2>=0) && (y2>=0)) {
        	highlight(x1, y1, x2, y2);
            return TRUE;
        }
        else
        	return FALSE;
    }
    else
    	return FALSE;
}

default
{
    state_entry()
    {
        board = initBoard;
        list values = llGetLinkPrimitiveParams(LINK_THIS, [PRIM_SIZE]);
        size = llList2Vector(values, 0);
        unit.x = size.x / 8;
        unit.y = size.y / 8;
        setPlace("ActiveFrom", 3, 1);
        setPlace("ActiveTo", 3, 2);
        llListen(0, "", NULL_KEY, "");
    }

    on_rez(integer number)
    {
        llResetScript();
    }

    listen(integer channel, string name, key id, string message)
    {
     	if (channel == 0) {
        	try_move(message);
        }
    }
}
