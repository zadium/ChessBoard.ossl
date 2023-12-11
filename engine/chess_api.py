"""
    @name: chess_api
    @description: chess rest api server to accept fen format, to check move and result best move, using stockfish.
    @author: Zai Dium
    @update: 2022-02-16
    @version: 1.1
    @revision: 1
    @localfile: ?defaultpath\Chess\?@name.lsl
    @license: by-nc-sa [https://creativecommons.org/licenses/by-nc-sa/4.0/]

This Python script is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.

You should have received a copy of the license along with this work. If not, see <https://creativecommons.org/licenses/by-nc-sa/4.0/>.

License information:
- Attribution: You must give appropriate credit, provide a link to the license, and indicate if changes were made.
- NonCommercial: You may not use this work for commercial purposes.
- ShareAlike: If you remix, transform, or build upon this work, you must distribute your contributions under the same license as the original.

"""
from Chessnut import Game
from Chessnut.game import InvalidMove
from pystockfish import *

import colorama
from fastapi import FastAPI
from threading import Lock
import ssl
import uvicorn

"""
    Level 1: Skill -9, Depth 5, 50ms
    Level 2: Skill -5, Depth 5, 100ms
    Level 3: Skill -1, Depth 5, 150ms
    Level 4: Skill 3, Depth 5, 200ms
    Level 5: Skill 7, Depth 5, 300ms
    Level 6: Skill 11, Depth 8, 400ms
    Level 7: Skill 16, Depth 13, 500ms
    Level 8: Skill 20, Depth 22, 1000ms
"""

colorama.init()

lock = Lock()
sequance = 0
app = FastAPI()

games = []

# Define a function to find an object by UUID
def find_game(uid):
    global games
    for obj in games:
        if obj.uid == uid:
            return obj
    return None

@app.get("/")
async def read_root():
    return {"result": "ok", "message": "ok"}

def try_move(game, move):
    try:
        game.apply_move(move)
    except InvalidMove as err:
        print("error:Invalid Move " + move+"\n")
        return False
    except Exception as err:
        print("\nerror:" + type(err).__name__ + ' message: ' + str(err).strip()+"\n")
        return False

    return True

@app.get("/{uid}/move/{move}")
async def set_move(uid: str, move: str, q: str = None):
    global sequance

    lock.acquire()
    try:
        sequance = sequance + 1
        game = find_game(uid)
        if game == None:
            return {
                "command": "move",
                "uid": uid,
                "seq": sequance,
                "result": "error",
                "message": "Game not found",
            }
    finally:
        lock.release()

    if try_move(game, move):

        if game.status < Game.CHECKMATE:
            fen = str(game)
            game.deep.setfenposition(fen)
            respond = game.deep.bestmove()
            bestmove = respond["move"]
            try_move(game, bestmove)
            print("bestmove: " + bestmove)

            #if game.status < Game.CHECKMATE:

        return {
            "command": "move",
            "uid": uid,
            "seq": sequance,
            "result": "ok",
            "message": "Ok",
            "move": move,
            "bestmove": bestmove
        }
    else:
        return {
            "command": "move",
            "uid": uid,
            "seq": sequance,
            "result": "error",
            "message": "Invalide Move",
            "move": move
        }

@app.get("/{uid}/fen/{fen}")
async def set_fen(uid: str, fen: str, q: str = None):
    global sequance
    return {
        "command": "fen",
        "uid": uid,
        "seq": sequance,
        "result": "ok",
        "message": "Ok",
        "bestmove": move
    }

@app.get("/{uid}/new/{depth}")
async def set_new(uid: str,q: str = None):
    global sequance

    lock.acquire()
    try:
        sequance = sequance + 1
        game = find_game(uid)

        if game != None:
            games.remove(game)

        game = Game();
        game.uid = uid
        games.append(game);

    finally:
        lock.release()

    game.deep = Engine(depth=6)
    return {
        "command": "new",
        "uid": uid,
        "seq": sequance,
        "result": "ok",
        "message": "Game created",
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=82)

    #ssl_context = ssl.create_default_context(ssl.Purpose.CLIENT_AUTH)
    #ssl_context.load_cert_chain(certfile="certificate.crt", keyfile="private.key")

    #uvicorn.run(app, host="0.0.0.0", port=8443,
    #				ssl_certfile="certificate.crt",
    #				ssl_keyfile="private.key",
    #				ssl_version=ssl.PROTOCOL_TLS,
    #				#ssl_context=ssl_context
    #			)