"""
This Python script is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.

You should have received a copy of the license along with this work. If not, see <https://creativecommons.org/licenses/by-nc-sa/4.0/>.

License information:
- Attribution: You must give appropriate credit, provide a link to the license, and indicate if changes were made.
- NonCommercial: You may not use this work for commercial purposes.
- ShareAlike: If you remix, transform, or build upon this work, you must distribute your contributions under the same license as the original.

"""
from Chessnut import Game
from Chessnut.game import InvalidMove
from colorama import init, Fore, Back, Style
from pystockfish import *

#init_fen = "rnbqkbnr/pp2pppp/8/3p4/8/5N2/PPPP1PPP/RNBQKB1R w KQkq - 0 1"
init_fen = "r1bqkbnr/p1pp1ppp/1pn5/4p3/2B1P3/5Q2/PPPP1PPP/RNB1K1NR w KQkq - 0 1"
## f3f7
deep = Engine(depth=6)

init(autoreset=True)

game = Game(init_fen)
#game.apply_move(move)

def print_fen():
    global game
    if game != None:
        print(game.board)

def print_board():
    global game

    if game != None:
        print("\n   a b c d e f g h")
        print("  –––––––––––––––––")
        row = 8
        print(str(row)+"|", end="")
        for index in range(64):
            piece = game.board.get_piece(index)
            if index > 0 and index % 8 == 0:
                print(" |"+str(row))
                row = row-1
                print(str(row)+"|", end="")
            print(" "+piece, end='')
        print(" |"+str(row))
        print("  –––––––––––––––––")
        print("   a b c d e f g h\n")
        print_state()

def new_game():
    global game
    game = Game()
    print(Fore.GREEN + "New game created")

def try_move(move):
    global game, deep
    if game == None:
        new_game()
    try:
        game.apply_move(move)
    except InvalidMove as err:
        print("\n"+Fore.RED+"Invalid Move " + move+"\n")
        return False
    except Exception as err:
        print("\n"+Fore.RED+"error:" + type(err).__name__ + ' message: ' + str(err).strip()+"\n")
        return False

    print(Fore.GREEN+"move: " + move)
    return True

def print_state():
    status = None
    if game.status == 1:
        status = Fore.RED+"Check"
    elif game.status == 2:
        status = Fore.RED+"Checkmate"
    elif game.status == 3:
        status = Fore.RED+"Stalemate"
    if(game.status != 0):
        print(status+"\n")

#print('\u2654')

while True:

    if game != None:
        if game.state.player == "b":
            player = "Black "
        else:
            player = "White "
    else:
        player = ""
    line = input(player + "Command » ");
    params = line.split(" ")
    cmd = params[0]
    del params[0]
    if cmd == "move":
        try_move(params[0])
        print_board()
    elif cmd == "print":
        if len(params)>0 and params[0] == "fen":
            print(game)
            print("")
        else:
            print_board()
    elif cmd == "new":
        new_game()
        print_board()
    elif cmd == "q" or cmd == "exit":
        break
    elif cmd == "":
        pass
    else:
        if game.status < Game.CHECKMATE:
            if try_move(cmd):
                print_board ()
                if game.status < Game.CHECKMATE:
                    fen = str(game)
                    deep.setfenposition(fen)
                    #print(deep.bestmove())
                    respond = deep.bestmove()
                    move = respond["move"]
                    try_move(move)

                    print_board()