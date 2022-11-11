/**
    @name: ChessBoard
    @description:

    @author: Zai Dium
    @update: 2022-02-16
    @revision: 595
    @localfile: ?defaultpath\Chess\?@name.lsl
    @license: MIT

    @notice:

    FEN notation

        https://www.chessprogramming.org/Forsyth-Edwards_Notation#Shredder-FEN
        https://gbud.in/blog/game/chess/chess-fen-forsyth-edwards-notation.html#castling-availability

/** Options **/
string token = "";
key http_request_id;

integer debug_mode = TRUE;
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
    "Rook",
    "Bishop",
    "Knight",
    "Pawn"
];

list p = [
    "k",
    "q",
    "r",
    "b",
    "n",
    "p"
];

//* Piece color List by color used when rez to give names
list pNames = [
    "kw",
    "qw",
    "rw",
    "bw",
    "nw",
    "pw",

    "kb",
    "qb",
    "rb",
    "bb",
    "nb",
    "pb"
];

//* Piece color List by color as FEN format
list fenNames = [
    "K",
    "Q",
    "R",
    "B",
    "N",
    "P",

    "k",
    "q",
    "r",
    "b",
    "n",
    "p"
];

//* initial board
list InitBoard =
[
    "pb", "pb", "pb", "pb", "pb", "pb", "pb", "pb",
    "rb", "nb", "bb", "qb", "kb", "bb", "nb", "rb",
    "",   "",   "",   "",   "",   "",   "",   "",
    "",   "",   "",   "",   "",   "",   "",   "",
    "",   "",   "",   "",   "",   "",   "",   "",
    "",   "",   "",   "",   "",   "",   "",   "",
    "pw", "pw", "pw", "pw", "pw", "pw", "pw", "pw",
    "rw", "nw", "bw", "qw", "kw", "bw", "nw", "rw"
];

list EmptyBoard =
[
    "", "", "", "", "", "", "", "",
    "", "", "", "", "", "", "", "",
    "", "", "", "", "", "", "", "",
    "", "", "", "", "", "", "", "",
    "", "", "", "", "", "", "", "",
    "", "", "", "", "", "", "", "",
    "", "", "", "", "", "", "", "",
    "", "", "", "", "", "", "", ""
];

list EmptyKeys =
[
    NULL_KEY, NULL_KEY, NULL_KEY, NULL_KEY, NULL_KEY, NULL_KEY, NULL_KEY, NULL_KEY,
    NULL_KEY, NULL_KEY, NULL_KEY, NULL_KEY, NULL_KEY, NULL_KEY, NULL_KEY, NULL_KEY,
    NULL_KEY, NULL_KEY, NULL_KEY, NULL_KEY, NULL_KEY, NULL_KEY, NULL_KEY, NULL_KEY,
    NULL_KEY, NULL_KEY, NULL_KEY, NULL_KEY, NULL_KEY, NULL_KEY, NULL_KEY, NULL_KEY,
    NULL_KEY, NULL_KEY, NULL_KEY, NULL_KEY, NULL_KEY, NULL_KEY, NULL_KEY, NULL_KEY,
    NULL_KEY, NULL_KEY, NULL_KEY, NULL_KEY, NULL_KEY, NULL_KEY, NULL_KEY, NULL_KEY,
    NULL_KEY, NULL_KEY, NULL_KEY, NULL_KEY, NULL_KEY, NULL_KEY, NULL_KEY, NULL_KEY,
    NULL_KEY, NULL_KEY, NULL_KEY, NULL_KEY, NULL_KEY, NULL_KEY, NULL_KEY, NULL_KEY
];

printBoard()
{
	integer x = 0;
    integer y = 0;
    string s;
    string name;
    while (y < 8) {
        x = 0;
//        if (y != 0)
		    s += "\n";
        while (x < 8) {
        	if (x != 0)
				s += " ";
            name = getSquareName(x, y);
            if (name =="")
            	name = "--";
            s += name;
            x++;
        }
        y++;
    }
    llSay(0, s);
}
list moves; //* list of moves from begining

list board;
list keys;
//*------------------------------------*//
string getSquareName(integer x, integer y)
{
    integer index = x * 8 + y;
    return llList2String(board, index);
}

setSquareName(integer x, integer y, string piece)
{
    integer index = x * 8 + y;
    board = llListReplaceList(board, [piece], index, index);
}

string getSquareID(integer x, integer y)
{
    integer index = x * 8 + y;
    return llList2String(keys, index);
}

setSquareID(integer x, integer y, string piece)
{
    integer index = x * 8 + y;
    keys = llListReplaceList(keys, [piece], index, index);
}
//*------------------------------------*//


vector unit;
vector size;

key player_white = NULL_KEY;
key player_black = NULL_KEY;

vector from_place = <0, 0, 0>; //* used to detect of set, if z = 1 it is set, of 0 not set
vector to_place = <0, 0, 0>;

integer active_link;
integer link_perm = FALSE;

integer PIN = 1;
string ScriptUpdate = "Piece";

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
    if (id == NULL_KEY)
        return -1;
    integer c = llGetNumberOfPrims();
    integer i = 1; //based on 1
    while(i <= c)
    {
        if (llGetLinkKey(i) == id) // llGetLinkName based on 1
            return i;
        i++;
    }
    llOwnerSay("Could not find key: " + (string)id);
    return -1;
}

//*
vector calcPos(float x, float y) {
    x = x * unit.x - size.x / 2 + unit.x / 2;
    y = y * unit.y - size.y / 2 + unit.y / 2;
    list values = llGetLinkPrimitiveParams(LINK_ROOT, [PRIM_POS_LOCAL]);
    vector pos = llList2Vector(values, 0);
    return <x, y, 0>;
}

//* coordinates by meters (inworld)
setLinkPos(integer index, vector pos){
    list values = llGetLinkPrimitiveParams(index, [PRIM_SIZE]);
    vector s = llList2Vector(values, 0);
    pos.z = s.z / 2 + size.z / 2;
    llSetLinkPrimitiveParamsFast(index, [PRIM_POSITION, pos]);
}

//* coordinates 0-7, 0-7
setLinkPlace(integer link, integer x, integer y){
    vector pos = calcPos(x, y);
    if (link >= 0)
        setLinkPos(link, pos);
    else
        llOwnerSay("Error: You can move non exists link");
}

//* coordinates 0-7, 0-7
setPlaceByKey(key k, float x, float y){
    vector pos = calcPos(x, y);
    integer index = getLinkByKey(k);
    if (index >= 0)
        setLinkPos(index, pos);
}

//* coordinates 0-7, 0-7
setPlaceByName(string name, float x, float y){
    vector pos = calcPos(x, y);
    integer index = getLinkByName(name);
    if (index >= 0)
        setLinkPos(index, pos);
}

integer movePiece(integer x1, integer y1, integer x2, integer y2, integer kill)
{
    string p = getSquareName(x1, y1);
    key k = getSquareID(x1, y1);
    if (k != NULL_KEY)
    {
        setSquareName(x1, y1, "");
        setSquareName(x2, y2, p);

        setSquareID(x1, y1, NULL_KEY);
        setSquareID(x2, y2, k);

        //setPlaceByKey(k, x2, y2);
        //setPlace()
        return TRUE;
    }
    else
        return FALSE;
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
    setPlaceByName("ActiveFrom", x1, y1);
    setPlaceByName("ActiveTo", x2, y2);
}

tryMove(integer x1, integer y1, integer x2, integer y2)
{
//    setPlaceByName("ActiveFrom", x1, y1);
//    setPlaceByName("ActiveTo", x2, y2);
    movePiece((integer)x1, (integer)y1, (integer)x2, (integer)y2, TRUE);
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
            tryMove(x1, y1, x2, y2);
            return TRUE;
        }
        else
            return FALSE;
    }
    else
        return FALSE;
}

string guessName(integer index) {
    return llList2String(pNames, index); //* yes -1 based on 0
}

list rez_places = [];

rezObject(string name, integer param)
{
    rotation rot = llGetRot();
    vector pos = llGetPos();
    llRezObject(name, pos, <0, 0, 0>, rot, param);
}

rezPiece(string name, integer black, float place_x, float place_y)
{
    integer index = llListFindList(pieces, [name]);
    if (black) {
        index += llGetListLength(pieces);
        rez_places += <place_x, place_y, index>;
    }
    else
        rez_places += <place_x, place_y, index>;
    rezObject(name, index + 1); //* +1 to recive it in object
}

rezObjects(){
    rezPiece("Rook", TRUE, 0, 7);
    rezPiece("Knight", TRUE, 1, 7);
    rezPiece("Bishop", TRUE, 2, 7);
    rezPiece("King", TRUE, 3, 7);
    rezPiece("Queen", TRUE, 4, 7);
    rezPiece("Bishop", TRUE, 5, 7);
    rezPiece("Knight", TRUE, 6, 7);
    rezPiece("Rook", TRUE, 7, 7);

    rezPiece("Pawn", TRUE, 0, 6);
    rezPiece("Pawn", TRUE, 1, 6);
    rezPiece("Pawn", TRUE, 2, 6);
    rezPiece("Pawn", TRUE, 3, 6);
    rezPiece("Pawn", TRUE, 4, 6);
    rezPiece("Pawn", TRUE, 5, 6);
    rezPiece("Pawn", TRUE, 6, 6);
    rezPiece("Pawn", TRUE, 7, 6);

    rezPiece("Rook", FALSE, 0, 0);
    rezPiece("Knight", FALSE, 1, 0);
    rezPiece("Bishop", FALSE, 2, 0);
    rezPiece("King", FALSE, 3, 0);
    rezPiece("Queen", FALSE, 4, 0);
    rezPiece("Bishop", FALSE, 5, 0);
    rezPiece("Knight", FALSE, 6, 0);
    rezPiece("Rook", FALSE, 7, 0);

    rezPiece("Pawn", FALSE, 0, 1);
    rezPiece("Pawn", FALSE, 1, 1);
    rezPiece("Pawn", FALSE, 2, 1);
    rezPiece("Pawn", FALSE, 3, 1);
    rezPiece("Pawn", FALSE, 4, 1);
    rezPiece("Pawn", FALSE, 5, 1);
    rezPiece("Pawn", FALSE, 6, 1);
    rezPiece("Pawn", FALSE, 7, 1);
}

newBoard()
{
    rezObjects();
}

clearBoard(){
    integer c = llGetNumberOfPrims();
    integer i = 1; //based on 1
    list l;
    while(i <= c)
    {
        if (llListFindList(pNames, [llGetLinkName(i)])>=0) //* llGetLinkName based on 1
        {
            //llBreakLink(i);
            l += [llGetLinkKey(i)];
        }
        i++;
    }

    i = 0;
    integer index = 0;
    while (i<llGetListLength(l)) {
        index = getLinkByKey(llList2Key(l, i));
        if (index>0)
            llBreakLink(index);
        i++;
    }
}

resized()
{
    list values = llGetLinkPrimitiveParams(LINK_THIS, [PRIM_SIZE]);
    size = llList2Vector(values, 0);
    unit.x = size.x / 8;
    unit.y = size.y / 8;
}

touched(vector p) {
    list values = llGetLinkPrimitiveParams(LINK_THIS, [PRIM_POSITION, PRIM_ROTATION]);
    vector center = llList2Vector(values, 0);
    p = (p - center) / llList2Rot(values, 1);
    p = (p + <size.x / 2, size.y / 2, 0>); //* Shift to make 0,0 in bottom left of board
    vector v = <llFloor(p.x / unit.x), llFloor(p.y / unit.y), 0>; //* calc sequares numbers
    if (start_move == TRUE) {
        to_place = v;
        start_move = FALSE;
        setPlaceByName("ActiveTo", to_place.x, to_place.y);
        tryMove(llFloor(from_place.x), llFloor(from_place.y), llFloor(to_place.x), llFloor(to_place.y));
    }
    else {
        from_place = v;
        setPlaceByName("ActiveFrom", from_place.x, from_place.y);
        start_move = TRUE;
    }
}

//* detect pieces positions fill the lists
initialize(){
	llSay(0, "Reading board ...");
    board = EmptyBoard;
    keys = EmptyKeys;
    moves = []; //* list of moves from begining

    integer c = llGetNumberOfPrims();
    integer i = 1; //based on 1
    while(i <= c)
    {
    	string name = llGetLinkName(i);
        key id = llGetLinkKey(i);
        if (llListFindList(pNames, [name]) >= 0)
        {
            list values = llGetLinkPrimitiveParams(i, [PRIM_POS_LOCAL]);
            vector p = llList2Vector(values, 0);
            integer x = llCeil(p.x / unit.x) + 3;
            integer y = llCeil(p.y / unit.y) + 3;
        	llOwnerSay("found " + name + " in " + (string)x+"," +(string)y);
            setSquareName(x, y, name);
            setSquareID(x, y, id);
        }
        i++;
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

    l += ["New"];
    l += ["Clear"];
    l += ["Token"];
    l += ["Account"];
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

        board = InitBoard;
        resized();
        setPlaceByName("ActiveFrom", 0, 0);
        setPlaceByName("ActiveTo", 0, 2);
        initialize();
        llListen(0, "", NULL_KEY, "");
    }

    on_rez(integer number)
    {
        llResetScript();
    }

    run_time_permissions(integer perm)
    {

        if (perm & PERMISSION_CHANGE_LINKS)
            link_perm = TRUE;
        else
            llOwnerSay("Can't link objects.");
    }

    object_rez(key id)
    {
        llCreateLink(id, TRUE);
        integer index = getLinkByKey(id);
        //llGiveInventory(id, "Piece");
/*        if (debug_mode)
            llRemoteLoadScriptPin(id, ScriptUpdate, dialog_channel + PIN, TRUE, 0);*/
        vector v = llList2Vector(rez_places, 0);
        rez_places = llDeleteSubList(rez_places, 0, 0);

        string name = guessName((integer)v.z);
        vector color;
        rotation rot = llList2Rot(llGetLinkPrimitiveParams(index, [PRIM_ROT_LOCAL]), 0);
        if (llGetSubString(name, 1, 1) == "b")
        {
            color = <0.15, 0.15, 0.15>;
            rot = rot * llEuler2Rot(<0, 0, PI>);
        }
        else {
            color = <0.9, 0.9, 0.9>;
        }
        llSetLinkPrimitiveParamsFast(index, [PRIM_NAME, name, PRIM_ROT_LOCAL, rot, PRIM_COLOR, ALL_SIDES, color, 1.0, PRIM_BUMP_SHINY, ALL_SIDES, PRIM_SHINY_LOW, PRIM_BUMP_NONE]);
        setLinkPlace(index, (integer)v.x, (integer)v.y);
        setSquareID((integer)v.x, (integer)v.y, id);
    }

    changed(integer change)
    {
        if (change & CHANGED_SCALE)
            resized();
    }

    touch_start(integer num_detected)
    {
        key id = llDetectedKey(0);
        if(llGetPermissionsKey() != id)
        {
            llSay(0, "Please give permission to link and unlink");
//            llRequestPermissions(avatar, PERMISSION_TRIGGER_ANIMATION);
            llRequestPermissions(id, PERMISSION_CHANGE_LINKS);
        }
        else
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
    }

    link_message( integer sender_num, integer num, string str, key id )
    {
        if (str=="touch") {
            list values = llGetLinkPrimitiveParams(sender_num, [PRIM_POSITION]);
            vector p = llList2Vector(values, 0);
            touched(p);
        }
    }


    http_response(key request_id, integer status, list metadata, string body)
    {
        llSay(0, llJsonGetValue(body, ["id"]));
    }

    listen(integer channel, string name, key id, string message)
    {
        if (channel == 0) {
        	if (llToLower(message) == "/print board")
            	printBoard();
            else
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
                    llSay(0, "White has left");
                } else if (player_black == id) {
                    player_black = NULL_KEY;
                    llSay(0, "Black has left");
                } else {
                    llSay(0, "You are not registered to leave");
                }
            }
            else if (message == "new" ) {
                newBoard();
            }
            else if (message == "clear" ) {
                clearBoard();
            }
            else if (message == "account" )
            {
                http_request_id = llHTTPRequest("https://lichess.org/api/account", [HTTP_METHOD, "GET", HTTP_CUSTOM_HEADER, "Authorization", "Bearer "+ token], "");
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
                    llSay(0, "White has already registered");
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
                    llSay(0, "Black has already registered");
                }
                showDialog(id);
            }
        }
    }
}
