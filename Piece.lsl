/**
    @name: Piece
    @author: Zai Dium
    @update: 2022-02-16
    @revision: 273
    @localfile: ?defaultpath\Chess\?@name.lsl
*/

integer piece_number = 0;

default
{
    state_entry()
    {
        if (llGetScriptState("ChessBoard"))
        	llSetScriptState(llGetScriptName(), FALSE); //* stop it
    }

    on_rez(integer number)
    {
    	piece_number = number;
        if (number>0)
        {
             llSetObjectDesc(("piece"));
        }
        else if (llGetScriptState("ChessBoard"))
        	llSetScriptState(llGetScriptName(), FALSE); //* stop it
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
