# ChessBoard.ossl

Chess Board for OpenSim/SecondLife

## Steps

### Chess board

In object mode, select all, export as Dae file, Import it to opensim using Firestoarm, check lod as above to make it if you like (optional)

 * Rezz it in the world
 * Unlink all chessboard
 * Dublicate a small sequare to another one, name first one as ActiveFrom, name second one as ActiveTo, color it as you like, care about letter case
 * Link it again to the main board (colored white and black) as root
 * Copy ChessBoard.lsl into the root object
 * Copy Piece.lsl into ActiveFrom and ActiveTo sequares
 * Reset scripts

 ### Chess Pieces

 Export and import as same above

  * Rezz it in the world
  * Unlink all chessboard
  * Take it all
  * Rename it to right name, care about letter case, "King", "Queen", "Rock", "Bishop", "Knight", "Pown"
  * Copy it to into root of ChessBoard
  * Reset scripts
