/**
    @name: ChessBoard
    @description:

    @author: Zai Dium
    @update: 2022-02-16
    @revision: 368
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
list pc = [
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

//* initial board
list initBoard =
[
    "pb", "pb", "pb", "pb", "pb", "pb", "pb", "pb",
    "rb", "nb", "bb", "qb", "kb", "bb", "nb", "rb",
    "",   "",   "",   "",   "",   "",   "",    "",
    "",   "",   "",   "",   "",   "",   "",    "",
    "",   "",   "",   "",   "",   "",   "",    "",
    "",   "",   "",   "",   "",   "",   "",    "",
    "rw", "nw", "bw", "qw", "kw", "bw", "nw", "rw",
    "pw", "pw", "pw", "pw", "pw", "pw", "pw", "pw"
];

list board;
list moves; //* list of moves from begining

vector unit;
vector size;
key player_white = NULL_KEY;
key player_black = NULL_KEY;
vector from_place = <0, 0, 0>; //* used to detect of set, if z = 1 it is set, of 0 not set
vector to_place = <0, 0, 0>;

integer active_link;
integer link_perm = FALSE;

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

//*
vector calcPos(float x, float y) {
    x = x * unit.x - size.x / 2 + unit.x / 2;
    y = y * unit.y - size.y / 2 + unit.y / 2;
    list values = llGetLinkPrimitiveParams(LINK_ROOT, [PRIM_POS_LOCAL]);
    vector pos = llList2Vector(values, 0);
    return <x, y, size.z / 2 + 0.0001>;
}

//* coordinates by meters (inworld)
setPos(string name, vector pos){
    integer index = getLinkByName(name);
    if (index>0) {
        llSetLinkPrimitiveParams(index, [PRIM_POSITION, pos]);
    }
}

//* coordinates 0-7, 0-7
setPlace(string name, float x, float y){
    vector pos = calcPos(x, y);
    setPos(name, pos);
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

string guessName(integer index) {
    return llList2String(pc, index); //* yes -1 based on 0
}

rezObject(string name, integer param, float x, float y)
{
    rotation rot = llGetRot();
    vector pos = llGetPos();// + calcPos(x, y);
    llRezObject(name, pos, <0, 0, 0>, rot, param);
}

rezPiece(string name, integer black, float x, float y)
{
    integer index = llListFindList(pieces, [name]);
    if (black)
        index += llGetListLength(pieces);
    rezObject(name, index, x, y);
    //setPlace(guessName(index), x, y);
}

rezObjects(){
    rezPiece("Queen", FALSE, 1, 1);
//    rezPiece("Queen", TRUE, 6, 1);
}

resetBoard()
{
    rezObjects();
}

clearBoard(){
    integer c = llGetNumberOfPrims();
    integer i = 1; //based on 1
    while(i <= c)
    {
        if (llListFindList(pc, [llGetLinkName(i)])>=0) //* llGetLinkName based on 1
            llBreakLink(i);
        i++;
    }
}

resized()
{
    list values = llGetLinkPrimitiveParams(LINK_THIS, [PRIM_SIZE]);
    size = llList2Vector(values, 0);
    llOwnerSay("size "+(string)size);
    unit.x = size.x / 8;
    unit.y = size.y / 8;
    llOwnerSay("unit "+(string)unit);
}

touched(vector p) {
    llOwnerSay("------------------------------------------------------");
    //llOwnerSay("hina p "+(string)p);
    list values = llGetLinkPrimitiveParams(LINK_THIS, [PRIM_POSITION, PRIM_ROTATION]);
    vector center = llList2Vector(values, 0);

    rotation rot = llEuler2Rot(-llRot2Euler(llGetRot())); //* need to invert rotation of root object to correct pos
    //llOwnerSay("rot "+(string)(llRot2Euler(rot)*RAD_TO_DEG));
    //llOwnerSay("center "+(string)center);
    //llOwnerSay("p1 "+(string)p);
    p = (p - center);
    //llOwnerSay("c-p "+(string)p);
    p = p * rot;
    //llOwnerSay("p * rot "+(string)p);
    p = (p + <size.x / 2, size.y / 2, 0>); //* Shift to make 0,0 in bottom left of board
    //llOwnerSay("p2 "+(string)p);
    vector v = <llFloor(p.x / unit.x), llFloor(p.y / unit.y), 0>; //* calc sequares numbers
    //llOwnerSay("v "+(string)v);

    if (start_move == TRUE) {
        to_place = v;
        start_move = FALSE;
        setPlace("ActiveTo", to_place.x, to_place.y);
        try_move(llFloor(from_place.x), llFloor(from_place.y), llFloor(to_place.x), llFloor(to_place.y));
    }
    else {
        from_place = v;
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
        llOwnerSay("------------------------------------------------------");
        resized();
        setPlace("ActiveFrom", 0, 0);
        setPlace("ActiveTo", 0, 2);
        llListen(0, "", NULL_KEY, "");
        llRequestPermissions(llGetOwner(), PERMISSION_CHANGE_LINKS);
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
            llOwnerSay("Can't link.");
    }

    object_rez(key id)
    {
        llCreateLink(id, TRUE);
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
                    llSay(0, "White has left");
                } else if (player_black == id) {
                    player_black = NULL_KEY;
                    llSay(0, "Black has left");
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
