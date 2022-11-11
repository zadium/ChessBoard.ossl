/**
    @name: Piece
    @author: Zai Dium
    @update: 2022-02-16
    @revision: 241
    @localfile: ?defaultpath\Chess\?@name.lsl
*/

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

string guessName(integer index) {
    return llList2String(pc, index); //* yes -1 based on 0
}

default
{
    state_entry()
    {
    }

    on_rez(integer number)
    {
        if (number>0)
        {
            string name = guessName(number - 1); //* yes -1 based on 0
            llSetObjectName(name);
            if (llGetSubString(name, 1, 1) == "b")
                llSetColor(<0, 0, 0>, ALL_SIDES);
        }
    }

    touch(integer num_detected)
    {
        llMessageLinked(LINK_ROOT, llGetStartParameter(), "touch", llGetKey());
    }

    changed(integer change)
    {
        if (change & CHANGED_LINK)
        {
            if (llGetKey() == llGetLinkKey(LINK_ROOT)) {
                //llOwnerSay("Die");
                llDie();
            }
        }
    }

}
