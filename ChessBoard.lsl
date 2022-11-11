/**
    @name: ChessBoard
    @description:

    @author: Zai Dium
    @update: 2022-02-16
    @revision: 214
    @localfile: ?defaultpath\Chess\?@name.lsl
    @license: MIT

    @notice:

/** Options **/

integer owner_only = FALSE;

/** Consts **/

integer none = 0;
integer white = 1;
integer black = 2;

/** Variables **/

integer turn = 0;
integer start_move = 0;

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

//* lower case is black, upper case is white
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
list moves; //* list of moves from begining

vector unit;
vector size;
key player_white = NULL_KEY;
key player_black = NULL_KEY;
vector from_place = <0, 0, 0>; //z used to detect of set, if z = 1 it is set, of 0 not set
vector to_place = <0, 0, 0>;

integer active_link;

//* case sensitive

integer getLinkByName(string name)
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
    integer index = getLinkByName(name);
    if (index>0)
        return llGetLinkKey(index);
    else
        return NULL_KEY;
}

integer getLinkByKey(key id) {
    integer c = llGetNumberOfPrims();
    integer i = 1; //based on 1
    while(i <= c)
    {
        if (llGetLinkKey(i) == id) // llGetLinkName based on 1
            return i;
        i++;
    }
    llOwnerSay("Could not find " + (string)id);
    return -1;
}

//* coordinates by meters (inworld)
setPos(string name, float x, float y){
    integer index = getLinkByName(name);
    if (index>0) {
        list values = llGetLinkPrimitiveParams(LINK_ROOT, [PRIM_POS_LOCAL]);
        vector pos = llList2Vector(values, 0);
        pos = <x, y, size.z / 2 + 0.0001>;
        llSetLinkPrimitiveParams(index, [PRIM_POSITION, pos]);
    }
}

//* coordinates 0-7, 0-7
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

try_move(integer x1, integer y1, integer x2, integer y2)
{
}


//* try to highlight the move, then move a piece, using a string, example b2b4 or b2 b4
integer text_move(string msg) {
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
            //* TODO move a piece here after check if it valide move
            try_move(x1, y1, x2, y2);
            return TRUE;
        }
        else
            return FALSE;
    }
    else
        return FALSE;
}

resetBoard(){
}

clearBoard(){
}

resized()
{
    list values = llGetLinkPrimitiveParams(LINK_THIS, [PRIM_SIZE]);
    size = llList2Vector(values, 0);
    unit.x = size.x / 8;
    unit.y = size.y / 8;
}

touched(vector p) {
    list values = llGetLinkPrimitiveParams(LINK_ROOT, [PRIM_POSITION]);
    p = llList2Vector(values, 0) - p + <size.x / 2, size.y / 2, 0>;
    if (start_move == TRUE) {
        to_place = <(integer)(p.x / unit.x), (integer)(p.y / unit.y), 0>;
        start_move = FALSE;
        setPlace("ActiveTo", to_place.x, to_place.y);
        try_move((integer)from_place.x, (integer)from_place.y, (integer)to_place.x, (integer)to_place.y);

    }
    else {
        from_place = <(integer)(p.x / unit.x), (integer)(p.y / unit.y), 0>;
        setPlace("ActiveFrom", from_place.x, from_place.y);
        start_move = TRUE;
    }
}

key toucher_id;
integer dialog_channel;
integer cur_page; //* current menu page
integer dialog_listen_id;

list getCmdList(key id, integer owner) {
    list l = [];
	if (player_white == NULL_KEY)
    	l += ["White"];
    else
    	l += ["-"];
	if (player_black == NULL_KEY)
    	l += ["Black"];
    else
    	l += ["-"];
	if (player_white == id)
    	l += ["Leave"];
    else if (player_black == id)
    	l += ["Leave"];
    else
    	l += ["-"];

    l += ["Reset"];
    l += ["Clear"];
	// Abandon
    // Resign
    return l;
}

list cmd_list = [ "<--", "---", "-->" ]; //* general navigation

list getCommands(key id, integer owner)
{
    //llOwnerSay("page " + (string)page);
    //listList(gates_name_list);
    list commands = getCmdList(id, owner);
    integer length = llGetListLength(commands);
    if (length >= 9)
    {
        integer x = cur_page * 9;
        return cmd_list + llList2List(commands, x , x + 8);
    }
    else {
        return cmd_list + commands;
    }
}

showDialog(key id)
{
    llListenRemove(dialog_listen_id);
    integer owner = FALSE;
    if(!owner_only || (toucher_id == llGetOwner())) {
        owner = TRUE;
    }
    llDialog(id, "Commands", getCommands(id, owner), dialog_channel);
    dialog_listen_id = llListen(dialog_channel, "", id, "");
}

default
{
    state_entry()
    {
    	dialog_channel = -1 - (integer)("0x" + llGetSubString( (string) llGetKey(), -7, -1) );

        board = initBoard;
        resized();
        setPlace("ActiveFrom", 3, 1);
        setPlace("ActiveTo", 3, 2);
        llListen(0, "", NULL_KEY, "");
    }

    on_rez(integer number)
    {
        llResetScript();
    }

    changed(integer change)
    {
    	if (change & CHANGED_SCALE)
        	resized();
    }

    touch_start(integer num_detected)
    {
    	key id = llDetectedKey(0);
        integer link = llDetectedLinkNumber(0);
        if (link == getLinkByName("ChessFrame"))
        	showDialog(id);
    	else if (link == 1) {  //* 1 is the root CheadBoard
        	vector p = llDetectedTouchPos(0);
			touched(p);
        }
    }

    link_message( integer sender_num, integer num, string str, key id )
    {
        if (str=="touch") {
	        list values = llGetLinkPrimitiveParams(sender_num, [PRIM_POSITION]);
    	    vector p = llList2Vector(values, 0);
    		touched(p);
    	}
    }

    listen(integer channel, string name, key id, string message)
    {
    	if (channel == 0) {
            text_move(message);
        }
        else if (channel == dialog_channel)
        {
        	integer owner = FALSE;
            if(!owner_only || (toucher_id == llGetOwner())) {
                owner = TRUE;
            }

            llListenRemove(dialog_listen_id);

            message = llToLower(message);
            if (message == "---")
            {
                cur_page = 0;
                showDialog(id);
            }
            else if (message == "<--")
            {
                if (cur_page > 0)
                    cur_page--;
                showDialog(id);
            }
            else if (message == "-->")
            {
                integer max_limit = llGetListLength(getCmdList(id, owner)) / 9;
                if (max_limit >= 1 && cur_page < max_limit)
                    cur_page++;
                showDialog(id);
            }
            else if (message == "leave" ) {
            	if (player_white == id) {
					player_white = NULL_KEY;
                    llSay(0, "White is left");
                } else if (player_black == id) {
					player_black = NULL_KEY;
                    llSay(0, "Black is left");
                } else {
                    llSay(0, "You are not registered to leave");
                }
            }
            else if (message == "reset" ) {
            	resetBoard();
            }
            else if (message == "clear" ) {
            	clearBoard();
            }
            else if (message == "white" ) {
            	if (player_white == NULL_KEY) {
                	player_white = id;
                    if (player_black = id)
	                    player_black = NULL_KEY;
                    else
                    	llSay(0, "Battle!");
                }
                else {
                	llSay(0, "White is already registered");
                }
                showDialog(id);
            }
            else if (message == "black" ) {
            	if (player_black == NULL_KEY) {
                	player_black = id;
                    if (player_white = id)
	                    player_white = NULL_KEY;
                    else
                    	llSay(0, "Battle!");
                }
                else {
                	llSay(0, "Black is already registered");
                }
                showDialog(id);
            }
        }
    }
}
