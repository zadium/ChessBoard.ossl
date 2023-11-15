# ChessBoard.ossl

Chess Board for OpenSim/SecondLife

## License (CC BY-NC-SA 4.0)

Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International

https://creativecommons.org/licenses/by-nc-sa/4.0/

![ScreenShot](https://github.com/zadium/ChessBoard.ossl/assets/111429928/113e9fad-dc7c-48e7-8222-e4652a0dc238)

## Steps

### Chess board


In Blender in object mode, select all, export as Dae file, Import it to opensim using Firestoarm, check lod as above to make it if you like (optional)

 * Rezz it in the world
 * Unlink all chessboard objects
 * Dublicate a small sequare to another one, name first one as ActiveFrom, name second one as ActiveTo, color it as you like, care about letter case
 * Link it again to the main board (colored white and black) as root
 * Copy ChessBoard.lsl into the root object
 * Copy Piece.lsl into ActiveFrom and ActiveTo sequares
 * Reset scripts

 ### Chess Pieces

 Export and import as same above

  * Rezz it in the world
  * Set texture and color to white
  * Unlink all chessboard
  * Rename it to right name, care about letter case, "King", "Queen", "Rook", "Bishop", "Knight", "Pown"
  * Copy Piece.lsl script into each one
  * Take it all
  * Copy it to into root of ChessBoard
  * Reset scripts

 ## FEN notation

https://www.chessprogramming.org/Forsyth-Edwards_Notation#Shredder-FEN
https://gbud.in/blog/game/chess/chess-fen-forsyth-edwards-notation.html#castling-availability
https://www.chessprogramming.org/Forsyth-Edwards_Notation#Shredder-FEN

## Competitions

https://sites.google.com/site/azinsecondlife/chess

https://www.turbosquid.com/3d-models/3d-chess-board-chessboard-1679167

## Textures

https://www.sketchuptextureclub.com/textures/architecture/wood/fine-wood/dark-wood

## References

https://www.dubrovnikchessmen.com/chessmen-design-evolution.html

https://www.chess.com/forum/view/chess-equipment/atheist-chess-pieces
