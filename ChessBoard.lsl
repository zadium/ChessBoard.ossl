/**
    @name: ChessBoard
    @description:
    @author: Zai Dium
    @update: 2022-02-16
    @version: 1.19
    @revision: 1061
    @localfile: ?defaultpath\Chess\?@name.lsl
    @license: by-nc-sa [https://creativecommons.org/licenses/by-nc-sa/4.0/]

    @notice:

    FEN notation

        https://www.chessprogramming.org/Forsyth-Edwards_Notation#Shredder-FEN
        https://gbud.in/blog/game/chess/chess-fen-forsyth-edwards-notation.html#castling-availability

/** Options **/

integer debug_mode = TRUE;
integer owner_only = FALSE;

/** Consts **/

integer white = 0;
integer black = 1;

integer STATE_NONE = 0;
integer STATE_TV = 1;
integer STATE_FREE = 2;
integer STATE_AI = 3;

/** Variables **/

string default_fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";

integer turn = 0; //* 0 = white 1 = black

integer start_move = 0; //* when click first plot to start move

string token = "";

list pieces = [
    "King",
    "Queen",
    "Rook",
    "Bishop",
    "Knight",
    "Pawn"
];

list names = [
    "k", "q", "r", "b", "n", "p"
];

//* Piece color List by color used when rez to give names
list fenNames = [
    "K", "Q", "R", "B", "N", "P",
    "k", "q", "r", "b", "n", "p"
];

//* initial board
list InitBoard =
[
    "p", "p", "p", "p", "p", "p", "p", "p",
    "r", "n", "b", "q", "k", "b", "n", "r",
    "",  "",  "",  "",  "",  "",  "",  "",
    "",  "",  "",  "",  "",  "",  "",  "",
    "",  "",  "",  "",  "",  "",  "",  "",
    "",  "",  "",  "",  "",  "",  "",  "",
    "P", "P", "P", "P", "P", "P", "P", "P",
    "R", "N", "B", "Q", "K", "B", "N", "R"
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
    llSay(0, "Board\n");
    integer x = 0;
    integer y = 7;
    string s;
    string name;
    while (y >= 0) {
        x = 0;
//        if (y != 0)
            s += "\n";
        while (x < 8) {
            if (x != 0)
                s += " ";
            name = getBoardPlot(x, y);
            if (name =="" || name == " ")
                name = ".";
            name = llChar(0xFF21+llOrd(name, 0)-65);
            s += name;
            x++;
        }
        y--;
    }
    llSay(0, s);
}

list moves; //* list of moves from begining
list board;
list keys;

//*------------------------------------*//
string getBoardPlot(integer x, integer y)
{
    integer index = y * 8 + x;
    //llOwnerSay((string)x+","+(string)y+" " +llList2String(board, index));
    return llList2String(board, index);
}

setBoardPlot(integer x, integer y, string piece)
{
    integer index = y * 8 + x;
    board = llListReplaceList(board, [piece], index, index);
}

string getPlotID(integer x, integer y)
{
    integer index = y * 8 + x;
    return llList2String(keys, index);
}

setPlotID(integer x, integer y, string piece)
{
    integer index = y * 8 + x;
    keys = llListReplaceList(keys, [piece], index, index);
}

//*------------------------------------*//

vector unit;
vector size;

key player_white = NULL_KEY;
key player_black = NULL_KEY;

vector from_place = <0, 0, 0>; //* used to detect of set, if z = 1 it is set, of 0 not set
vector to_place = <0, 0, 0>;

integer link_perm = FALSE;
integer perm_function = 0;

integer PIN = 1;
string ScriptUpdate = "Piece";

//* case sensitive

integer getLinkByKey(key id) {
    if (id == NULL_KEY)
        return -1;

    integer c = llGetNumberOfPrims() + 1; //* self not included
    integer i = 0; //based on 1
    while(i < c)
    {
        if (llGetLinkKey(i) == id)
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
    integer index = osGetLinkNumber(name);
    if (index >= 0)
        setLinkPos(index, pos);
}

//* coordinates 0-7, 0-7
showByName(string name, float x, float y, integer show){
    vector pos = calcPos(x, y);
    integer link = osGetLinkNumber(name);
    if (link >= 0)
    {
        setLinkPos(link, pos);
        vector color = llList2Vector(llGetLinkPrimitiveParams(link, [PRIM_COLOR, ALL_SIDES]), 0);
        if (show)
            llSetLinkPrimitiveParams(link, [PRIM_COLOR, ALL_SIDES, color, 1]);
        else
            llSetLinkPrimitiveParams(link, [PRIM_COLOR, ALL_SIDES, color, 0]);
    }
}

integer movePiece(integer x1, integer y1, integer x2, integer y2, integer kill)
{
    string p = getBoardPlot(x1, y1);

    key k = getPlotID(x1, y1);
    if (k != NULL_KEY)
    {
        setBoardPlot(x1, y1, "");
        setBoardPlot(x2, y2, p);

        setPlotID(x1, y1, NULL_KEY);
        setPlotID(x2, y2, k);

        setPlaceByKey(k, x2, y2);
        //setPlace()
        return TRUE;
    }
    else
        return FALSE;
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
integer text_move(string msg)
{
    integer c = llStringLength(msg);
    if ((c == 4) || ((c == 5) && (llGetSubString(msg, 2, 2) == " ")))
    {
        integer i = 0;
        integer x1 = llOrd(msg, i)-97;
        i++;
        integer y1 = llOrd(msg, i)-49;
        if (c == 5)
            i++;
        i++;
        integer x2 = llOrd(msg, i)-97;
        i++;
        integer y2 = llOrd(msg, i)-49;
        if ((x1>=0) && (y1>=0) && (x2>=0) && (y2>=0))
        {
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
    return llList2String(fenNames, index); //* yes -1 based on 0
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

setupBoard()
{
    rezObjects();
}

clearBoard(){
    llOwnerSay("Clearing Board");
    integer c = llGetNumberOfPrims();
    integer i = 1; //based on 1
    list l;
    while(i <= c)
    {
        if (llListFindList(fenNames, [llGetLinkName(i)])>=0) //* llGetLinkName based on 1
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

touch_xy(vector p) {
    list values = llGetLinkPrimitiveParams(LINK_THIS, [PRIM_POSITION, PRIM_ROTATION]);
    vector center = llList2Vector(values, 0);
    p = (p - center) / llList2Rot(values, 1);
    p = (p + <size.x / 2, size.y / 2, 0>); //* Shift to make 0,0 in bottom left of board
    vector v = <llFloor(p.x / unit.x), llFloor(p.y / unit.y), 0>; //* calc sequares numbers
    if (start_move == TRUE) {
        to_place = v;
        start_move = FALSE;
        showByName("ActiveTo", to_place.x, to_place.y, TRUE);
        tryMove(llFloor(from_place.x), llFloor(from_place.y), llFloor(to_place.x), llFloor(to_place.y));
    }
    else {
        from_place = v;
        setPlaceByName("ActiveFrom", from_place.x, from_place.y);
        showByName("ActiveTo", from_place.x, from_place.y, FALSE);
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
        if (llListFindList(fenNames, [name]) >= 0)
        {
            list values = llGetLinkPrimitiveParams(i, [PRIM_POS_LOCAL]);
            vector p = llList2Vector(values, 0);
            integer x = llCeil(p.x / unit.x) + 3;
            integer y = llCeil(p.y / unit.y) + 3;
            //llOwnerSay("found " + name + " in " + (string)x+"," +(string)y);
            setBoardPlot(x, y, name);
            setPlotID(x, y, id);
        }
        i++;
    }
}

integer isDigit(string ch)
{
    return (llOrd(ch, 0) >= 48) && (llOrd(ch, 0) <= 57);
}

integer isLower(string ch)
{
    return llOrd(ch, 0) >= 97;
}

setFen(string fen)
{
//    list board;
    board = [];

    list parts = llParseString2List(fen, [" "], []);
    fen = llList2String(parts, 0);
    turn = llList2String(parts, 1) == "b";

    integer len=llStringLength(fen);
    integer i=0;
    string ch = "";
    while (i<len)
    {
        ch = llGetSubString(fen, i, i);
        if (ch !="/")
        {
            if (isDigit(ch))
            {
                integer c = (integer)ch;
                integer i;
                for (i = 0; i< c ; i++)
                    board += [""];
            }
            else
                board += [ch];
        }
        i++;
    }
    integer c = llGetListLength(board)-64;
    if (c > 0)
    {
        integer i;
        for (i = 0; i< c ; i++)
            board += [" "];
    }
}

string getFen()
{
    integer count = llGetListLength(board);
    integer i = 0;
    string fen = "";
    string plot;
    integer spaces = 0;
    integer col = 0;
    integer row = 0;
    while (i<count)
    {
        plot = llList2String(board, i);
        if ((plot=="") || (plot==" "))
            spaces++;
        else
        {
            if (spaces>0)
            {
                fen += (string)spaces;
                spaces = 0;
            }
            fen += plot;
        }
        col++;
        if (col>7)
        {
            col=0;
            if (spaces>0)
            {
                fen += (string)spaces;
                spaces = 0;
            }
            if (row<7)
                fen += "/";
            row++;
        }
        i++;
    }
    if (turn)
        fen += " b";
    else
        fen += " w";
    return fen;
}

key toucher_id;
integer dialog_channel;
integer cur_page; //* current menu page
integer dialog_listen_id;

list getMenuList(key id, integer owner) {
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
    l += ["Setup"];
    l += ["Clear"];
//    l += ["Token"];
//    l += ["Account"];
    // Abandon
    // Resign
    return l;
}

list cmd_list = [ "<--", "---", "-->" ]; //* general navigation

list getCommands(key id, integer owner)
{
    //llOwnerSay("page " + (string)page);
    //listList(gates_name_list);
    list commands = getMenuList(id, owner);
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

        board = EmptyBoard;
        //
        setFen(default_fen);
        printBoard();
        resized();
        setPlaceByName("ActiveFrom", 0, 0);
        setPlaceByName("ActiveTo", 0, 2);
        initialize();
        llListen(0, "", NULL_KEY, "");
        llOwnerSay("Board is ready!");
    }

    on_rez(integer number)
    {
        llResetScript();
    }

    run_time_permissions(integer perm)
    {
        if (perm & PERMISSION_CHANGE_LINKS)
        {
            link_perm = TRUE;
            if (perm_function==1)
                setupBoard();
            else if (perm_function==2)
                clearBoard();
        }
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
        if (isLower(name))
        {
            color = <0.15, 0.15, 0.15>;
            rot = rot * llEuler2Rot(<0, 0, PI>);
        }
        else {
            color = <0.9, 0.9, 0.9>;
        }
        llSetLinkPrimitiveParamsFast(index, [PRIM_NAME, name, PRIM_ROT_LOCAL, rot, PRIM_COLOR, ALL_SIDES, color, 1.0, PRIM_BUMP_SHINY, ALL_SIDES, PRIM_SHINY_LOW, PRIM_BUMP_NONE]);
        setLinkPlace(index, (integer)v.x, (integer)v.y);
        setPlotID((integer)v.x, (integer)v.y, id);
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
        if (llGetLinkName(link) == "ChessFrame")
            showDialog(id);
        else if (link == 1) {  //* 1 is the root CheadBoard
            vector p = llDetectedTouchPos(0);
            touch_xy(p);
        }
        else //* a Piece touch_xy
        {
            list l = llGetLinkPrimitiveParams(link, [PRIM_NAME, PRIM_POSITION]);
            string name = llList2String(l, 0);
            if (llListFindList(fenNames, [name])>=0) //* only chess pieces can move
            {
                vector pos = llList2Vector(l, 1);
                touch_xy(pos);
            }
        }
    }

    link_message( integer sender_num, integer num, string message, key id )
    {
        list params = llParseStringKeepNulls(message,[" "],[""]);
        string cmd = llList2String(params, 0);
        if (cmd=="move")
        {
            string move = llList2String(params, 1);
        }
    }

    listen(integer channel, string name, key id, string message)
    {
        if (channel == 0)
        {
            if (llToLower(message) == "/print fen")
            {
                llOwnerSay(getFen());
            }
            else if (llToLower(message) == "/print board")
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
                integer max_limit = (llGetListLength(getMenuList(id, owner))-1) / 9;
                if (cur_page < max_limit)
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
            else if (message == "setup" ) {
                if(llGetPermissionsKey() != llDetectedKey(0))
                {
                    link_perm = FALSE;
                    perm_function = 1;
                    llSay(0, "Please give permission to link and unlink");
                    llRequestPermissions(id, PERMISSION_CHANGE_LINKS);
                }
                else
                    setupBoard();
            }
            else if (message == "clear" )
            {
                if(llGetPermissionsKey() != llDetectedKey(0))
                {
                    link_perm = FALSE;
                    perm_function = 2;
                    llSay(0, "Please give permission to link and unlink");
                    llRequestPermissions(id, PERMISSION_CHANGE_LINKS);
                }
                else
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