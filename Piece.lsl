/**
    @name: Piece
    @description:
    @author: Zai Dium
    @update: 2022-02-16
    @version: 1.19
    @revision: 277
    @localfile: ?defaultpath\Chess\?@name.lsl
    @license: MIT
*/

integer piece_number = 0;

default
{
    state_entry()
    {
    }

    on_rez(integer number)
    {
        piece_number = number;
        if (number>0)
        {
             llSetObjectDesc(("piece"));
        }
    }

    touch(integer num_detected)
    {
        if (llGetObjectDesc() == "piece")
            llMessageLinked(LINK_ROOT, llGetStartParameter(), "touch", llGetKey());
    }

    changed(integer change)
    {
        if (change & CHANGED_LINK)
        {
            if (llGetKey() == llGetLinkKey(LINK_ROOT)) {
                if (llGetObjectDesc() == "piece")
                    llDie();
            }
        }
    }

}
