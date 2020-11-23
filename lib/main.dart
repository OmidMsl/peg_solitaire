import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peg Solitaire',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // board and marbles of the game
  // true for fill places, false for empty places and null for invalid places
  List<List<bool>> board = new List(7);

  // BuildContext for creating dialogs
  BuildContext scaffoldContext;

  @override
  void initState() {
    // TODO: implement initState
    resetGame();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // calculating size for the marbles
    double itemSize = (MediaQuery.of(context).size.width - 60) / 7;
    return Scaffold(
      // appbar in top of page
      appBar: AppBar(
        title: Text(
          'پرش گیره',
          style: TextStyle(
              color: Colors.black,
              fontFamily: 'Homa',
              fontStyle: FontStyle.italic,
              fontSize: 24.0),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
              icon: Icon(
                Icons.replay,
                color: Colors.black87,
              ),
              onPressed: () {
                setState(() {
                  resetGame();
                });
              }),
        ],
      ),
      body: new Builder(
        builder: (BuildContext context) {
          scaffoldContext = context;
          return Container(
            // setting wooden background for page
            constraints: BoxConstraints.expand(),
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("images/Wood_background.jpg"),
                    fit: BoxFit.cover)),
            child: Stack(
              children: [
                Center(
                  child: SingleChildScrollView(
                                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(7, (col) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(7, (row) {
                            // invalid places
                            if (board[row][col] == null)
                              return Container(
                                width: itemSize,
                                height: itemSize,
                              );
                            // empty places
                            else if (!board[row][col])
                              return DragTarget(
                                builder: (context,
                                    List<List<int>> candidateData,
                                    rejectedData) {
                                  return Image.asset(
                                    'images/white.png',
                                    height: itemSize,
                                    width: itemSize,
                                  );
                                },
                                // check if the dragged marble can place here or not
                                onWillAccept: (data) {
                                  if (row == data[0]) {
                                    if (col == data[1] - 2) {
                                      return (board[row][col + 1]);
                                    } else if (col == data[1] + 2) {
                                      return (board[row][col - 1]);
                                    } else
                                      return false;
                                  } else if (col == data[1]) {
                                    if (row == data[0] - 2) {
                                      return (board[row + 1][col]);
                                    } else if (row == data[0] + 2) {
                                      return (board[row - 1][col]);
                                    } else
                                      return false;
                                  } else
                                    return false;
                                },
                                // manage marble movement
                                onAccept: (data) {
                                  if (row == data[0]) {
                                    if (col == data[1] - 2) {
                                      setState(() {
                                        board[row][col] = true;
                                        board[row][col + 1] = false;
                                        board[row][col + 2] = false;
                                      });
                                    } else if (col == data[1] + 2) {
                                      setState(() {
                                        board[row][col] = true;
                                        board[row][col - 1] = false;
                                        board[row][col - 2] = false;
                                      });
                                    }
                                  } else if (col == data[1]) {
                                    if (row == data[0] - 2) {
                                      setState(() {
                                        board[row][col] = true;
                                        board[row + 1][col] = false;
                                        board[row + 2][col] = false;
                                      });
                                    } else if (row == data[0] + 2) {
                                      setState(() {
                                        board[row][col] = true;
                                        board[row - 1][col] = false;
                                        board[row - 2][col] = false;
                                      });
                                    }
                                  }
                                  checkSituation();
                                },
                              );
                              // if place is fill with marble
                            else
                              return Draggable(
                                child: Image.asset(
                                  'images/green.png',
                                  height: itemSize,
                                  width: itemSize,
                                ),
                                data: [row, col],
                                feedback: Image.asset(
                                  'images/green.png',
                                  height: itemSize,
                                  width: itemSize,
                                ),
                                childWhenDragging: Image.asset(
                                  'images/white.png',
                                  height: itemSize,
                                  width: itemSize,
                                ),
                              );
                          }),
                        );
                      }),
                    ),
                  ),
                ),
                // creator data in end of the page
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'Created by: Omid Mosalmani',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // putting marbles in them places
  void resetGame() {
    for (int i = 0; i < 7; i++) {
      board[i] = new List(7);
      // invalid places => null
      for (int j = 0; j < 7; j++) {
        if ((i < 2 && j < 2) ||
            (i > 4 && j < 2) ||
            (i < 2 && j > 4) ||
            (i > 4 && j > 4))
          board[i][j] = null;
        // center place => empty
        else if (i == 3 && j == 3)
          board[i][j] = false;
        // other places => fill
        else
          board[i][j] = true;
      }
    }
  }

  // check if geme is over or player is winned
  void checkSituation() {
    // putting all fill places in list
    List<List<int>> bottons = [];
    for (int i = 0; i < 7; i++) {
      for (int j = 0; j < 7; j++) {
        if (board[i][j] != null && board[i][j]) {
          bottons.add([i, j]);
        }
      }
    }
    // if there is only one marble
    if (bottons.length == 1) {
      // if the only marble is in center player is winned otherwise player is lost
      if (bottons[0][0] == 3 && bottons[0][1] == 3) {
        showWinDialog();
      } else {
        showLoseDialog();
      }
    } else {
      // check that is all remain marbles departed from eachother or not
      bool endOfGame = true;
      for (List<int> cor in bottons) {
        if ((cor[1] < 6 &&
                board[cor[0]][cor[1] + 1] != null &&
                board[cor[0]][cor[1] + 1]) ||
            (cor[1] > 0 &&
                board[cor[0]][cor[1] - 1] != null &&
                board[cor[0]][cor[1] - 1]) ||
            (cor[0] < 6 &&
                board[cor[0] + 1][cor[1]] != null &&
                board[cor[0] + 1][cor[1]]) ||
            (cor[0] > 0 &&
                board[cor[0] - 1][cor[1]] != null &&
                board[cor[0] - 1][cor[1]])) {
          endOfGame = false;
          break;
        }
      }
      if (endOfGame) {
        showLoseDialog();
      }
    }
  }

  // winner message
  void showWinDialog() {
    showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 700),
      context: context,
      pageBuilder: (_, __, ___) {
        return Center(
          child: Container(
            height: 270,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: Colors.white,
                image: DecorationImage(
                    image: AssetImage("images/win.jpg"), fit: BoxFit.fitWidth)),
            child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FlatButton(
                        color: Colors.white70,
                        child: Text(
                          'بازی دوباره',
                          style: TextStyle(
                              fontFamily: 'Sans',
                              color: Colors.deepPurple[900]),
                        ),
                        onPressed: () {
                          setState(() {
                            resetGame();
                          });
                          Navigator.of(context).pop();
                        }),
                    FlatButton(
                        color: Colors.white70,
                        child: Text(
                          'خروج',
                          style: TextStyle(
                              fontFamily: 'Sans',
                              color: Colors.deepPurple[900]),
                        ),
                        onPressed: () {
                          SystemNavigator.pop();
                          Navigator.of(context).pop();
                        }),
                  ],
                )),
            margin: EdgeInsets.only(left: 12, right: 12),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
          child: child,
        );
      },
    );
  }

  // looser message
  void showLoseDialog() {
    showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 700),
      context: context,
      pageBuilder: (_, __, ___) {
        return Center(
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40), color: Colors.white),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'images/lose.jpg',
                  width: 100,
                  height: 100,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FlatButton(
                        child: Text(
                          'بازی دوباره',
                          style:
                              TextStyle(fontFamily: 'Sans', color: Colors.red),
                        ),
                        onPressed: () {
                          setState(() {
                            resetGame();
                          });
                          Navigator.of(context).pop();
                        }),
                    FlatButton(
                        child: Text(
                          'خروج',
                          style:
                              TextStyle(fontFamily: 'Sans', color: Colors.red),
                        ),
                        onPressed: () {
                          SystemNavigator.pop();
                          Navigator.of(context).pop();
                        }),
                  ],
                ),
              ],
            ),
            margin: EdgeInsets.only(left: 12, right: 12),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
          child: child,
        );
      },
    );
  }
}
