/**
    @name: Piece
    @author: Zai Dium
    @update: 2022-02-16
    @revision: 215
    @localfile: ?defaultpath\Chess\?@name.lsl
*/
default
{
    touch(integer num_detected)
    {
        llMessageLinked(LINK_ROOT, 0, "touch", llGetLinkNumber());
    }

}
