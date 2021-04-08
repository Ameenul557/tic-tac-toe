//importing required packages
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tic_tac_toe/provider.dart';


void main()
{
    //running the game
    runApp(MyGame());
}

class MyGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: ArrayProvider(), //consist of the values for the tic tac toe cells
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Material(
          child: HomeScreen() //calling main screen
        )
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var ap = Provider.of<ArrayProvider>(context,listen: false); //accessing the cell array for resetting the game after its over
    return Scaffold(
      body: Stack(
        children: [
          Container(
              height: double.infinity,
              width: double.infinity,
              child: Image.asset('assets/tt1.jpg',fit: BoxFit.fill,)//background image
          ),
          Center(
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    Container(
                      child: Center(
                        child: Text(
                          "Tic Tac Toe",
                          style: TextStyle(color: Colors.red,fontSize: 40,fontWeight: FontWeight.bold), //heading
                        ),
                      ),
                    ),
                    SizedBox(height: 40,),
                    //three buttons in the home screen
                    Container(
                      width: MediaQuery.of(context).size.width*0.4,
                      child: RaisedButton(
                        color: Colors.red,
                        child: Text(
                          "Play as X",
                          style: TextStyle(color: Colors.white,fontSize: 20),
                        ),
                        onPressed: () { //when the button is pressed creates new game,
                          for(int i=0;i<ap.arr.length;i++){
                            ap.arr[i]='';
                          }
                          Navigator.of(context).push(MaterialPageRoute( //moving to the game screen first move to human
                              builder: (context) => GameScreen('O','X')));
                        }
                      ),
                    ),
                    SizedBox(height: 20,),
                    Container(
                      width: MediaQuery.of(context).size.width*0.4,
                      child: RaisedButton(
                          color: Colors.red,
                          child: Text(
                            "Play as O",
                            style: TextStyle(color: Colors.white,fontSize: 20),
                          ),
                          onPressed: () {
                            for(int i=0;i<ap.arr.length;i++){
                              ap.arr[i]='';
                            }
                            Navigator.of(context).push(MaterialPageRoute( //moving to the game screen first move to ai
                                builder: (context) => GameScreen('X','O')));
                          }
                      ),
                    ),
                    SizedBox(height: 20,),
                    Container(
                      width: MediaQuery.of(context).size.width*0.4,
                      child: RaisedButton(
                        color: Colors.red,
                        child: Text(
                            "Quit",
                          style: TextStyle(color: Colors.white,fontSize: 20),
                        ),
                        onPressed: () =>exit(0), //exiting of app
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            child: Text(
                "Made by Ameenul with Flutter", //copy rights //trade mark :)
              style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
            ),
            bottom: 0.1,
            right: 10,
          )
        ],
      ),
    );
  }
}


class GameScreen extends StatefulWidget {
  final String ai,human;
  //getting who is gonna play x and who is y
  GameScreen(this.ai,this.human);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {

  bool isGameOver = false;
  bool humanTurn;
  String result;
  String ai,human;
  var scores;

  //initializer func
  void initState(){
    ai=widget.ai;
    human=widget.human;
    if(ai=='X'){
      //assigning scores for the ai
      scores = {
        'O':-10,
        'X':10,
        'draw':0
    };
      //determining whose gonna play first
      humanTurn=false;
    }
    else{
      scores = {
        'X':-10,
        'O':10,
        'draw':0
      };
      humanTurn=true;
    }
    super.initState();
  }

  //analysing score for each position for the ai to make the next best move
  int makeBestMove(){
    var ap =Provider.of<ArrayProvider>(context,listen: false);
    var bestScore = -10000000; //since int.infinity not available in dart soo used a big number
    int bestMove;
    for(int i=0;i<ap.arr.length;i++){
      if(ap.arr[i]==''){ //checking if the cell is empty or already marked
        ap.arr[i] = ai;
        var score = miniMax(ap.arr,0,false); //calling minimax for each position
        ap.arr[i] = '';
        if(score ==null) score=0;
        if(score>bestScore){
          bestScore=score; //checking and updating the best move
          bestMove = i;
        }
      }
    }
     return bestMove; //returning the best possible move for that turn
  }

  //minimax function it recursively find the shortest winning moves score and return the score
  int miniMax(List<String> partialArr,depth,isMaximizing){
    var res=miniMaxChecker(partialArr); //winning condition
    if(res!=null){ //if there is a winning case return score else continue recursion
      return scores[res];
    }
    //maximizing player is ai

    if(isMaximizing){
      var bestScore=-10000000;
      for(int i=0;i<partialArr.length;i++) {
        if (partialArr[i] == '') { //checking for cell availability
          partialArr[i] = ai; //ai taking move
          var score = miniMax(partialArr, depth+1, false); //recursively calling and passing turn to human player (to find his optimal move) //increasing depth by 1
          partialArr[i] =''; //resetting move or else the changes will be affected in ui
          if(score !=null) bestScore = max(score,bestScore); //updating  best score
        }
      }
      return bestScore-depth; //depth is subtracted in order to find one best move among several moves with same scores
    } else { //minimizing player human
      var bestScore=10000000;
      for(int i=0;i<partialArr.length;i++) {
        if (partialArr[i] == '') { //checking for cell availability
          partialArr[i] = human; //human taking move
          var score = miniMax(partialArr, depth+1, true);//recursively calling and passing turn to ai  //increasing depth by 1
          partialArr[i] =''; //resetting move or else the changes will be affected in ui
          if(score !=null) bestScore = min(score,bestScore);//updating  best score
        }
      }
      return bestScore+depth; //depth is added in order to find one best move among several moves with same scores for human
    }
  }

  //condition checker for minimax function
  String miniMaxChecker(List<String> arr){
    if((arr[0]=='O' && arr[1]=='O' && arr[2]=='O')  ||
        (arr[3]=='O' && arr[4]=='O' && arr[5]=='O') ||
        (arr[6]=='O' && arr[7]=='O' && arr[8]=='O') ||
        (arr[0]=='O' && arr[3]=='O' && arr[6]=='O') ||
        (arr[1]=='O' && arr[4]=='O' && arr[7]=='O') ||
        (arr[2]=='O' && arr[5]=='O' && arr[8]=='O') ||
        (arr[0]=='O' && arr[4]=='O' && arr[8]=='O') ||
        (arr[2]=='O' && arr[4]=='O' && arr[6]=='O')
    ){
      return 'O'; //if o wins
    }
    else if((arr[0]=='X' && arr[1]=='X' && arr[2]=='X')  ||
        (arr[3]=='X' && arr[4]=='X' && arr[5]=='X') ||
        (arr[6]=='X' && arr[7]=='X' && arr[8]=='X') ||
        (arr[0]=='X' && arr[3]=='X' && arr[6]=='X') ||
        (arr[1]=='X' && arr[4]=='X' && arr[7]=='X') ||
        (arr[2]=='X' && arr[5]=='X' && arr[8]=='X') ||
        (arr[0]=='X' && arr[4]=='X' && arr[8]=='X') ||
        (arr[2]=='X' && arr[4]=='X' && arr[6]=='X')
    ){
      return 'X'; //if x wins
    }
    else if(!(arr.any((element) => (element=='')))){
      return 'draw'; //if there is a tie
    }
    return null; //game is not ended
  }

  //game ending conditions for the ui and resetting array
  String gameEndingCondition(){
    var ap =Provider.of<ArrayProvider>(context);
    if((ap.arr[0]==ap.arr[1]&& ap.arr[1]==ap.arr[2] && ap.arr[0]!='' && ap.arr[1]!='' && ap.arr[2]!='')  ||
        (ap.arr[3]==ap.arr[4]&& ap.arr[4]==ap.arr[5] && ap.arr[3]!='' && ap.arr[4]!='' && ap.arr[5]!='') ||
        (ap.arr[6]==ap.arr[7]&& ap.arr[7]==ap.arr[8] && ap.arr[6]!='' && ap.arr[7]!='' && ap.arr[8]!='') ||
        (ap.arr[0]==ap.arr[3]&& ap.arr[3]==ap.arr[6] && ap.arr[0]!='' && ap.arr[3]!='' && ap.arr[6]!='') ||
        (ap.arr[1]==ap.arr[4]&& ap.arr[4]==ap.arr[7] && ap.arr[1]!='' && ap.arr[4]!='' && ap.arr[7]!='') ||
        (ap.arr[2]==ap.arr[5]&& ap.arr[5]==ap.arr[8] && ap.arr[2]!='' && ap.arr[5]!='' && ap.arr[8]!='') ||
        (ap.arr[0]==ap.arr[4]&& ap.arr[4]==ap.arr[8] && ap.arr[0]!='' && ap.arr[4]!='' && ap.arr[8]!='') ||
        (ap.arr[2]==ap.arr[4]&& ap.arr[4]==ap.arr[6] && ap.arr[2]!='' && ap.arr[4]!='' && ap.arr[6]!='')
    ){
      isGameOver=true;
      if(humanTurn){
        result = ai+" wins";
      }
      else{
        result = human+" wins";
      }
      for(int i=0;i<ap.arr.length;i++){
        ap.arr[i]='';
      }
      return result;
    }
    //if there is no place left to mark
    else if(!(ap.arr.any((element) => (element=='')))){
      isGameOver=true;
      result = "Draw";
      for(int i=0;i<ap.arr.length;i++){
        ap.arr[i]='';
      }
      return "draw";
    }
    return null;
  }

  //custom cell for entering x and o values
  Widget cell(String c){
    return Container(
      padding: EdgeInsets.zero,
      child: Center(child: Text(c,style: TextStyle(color: (c=='X')?Colors.red:Colors.indigo,fontWeight: FontWeight.bold,fontSize: 40),)),
      height: MediaQuery.of(context).size.width*0.5,
      width: MediaQuery.of(context).size.width*0.4,
      decoration: BoxDecoration(border: Border.all(width: 2)),
    );
  }

  //ui start building the app from this function
  @override
  Widget build(BuildContext context) {
    var ap =Provider.of<ArrayProvider>(context); // listening to array if there is any change the entire ui will be updated
    //checking game ending conditions
    gameEndingCondition();
    //checking whose turn
    if(!humanTurn){
      ap.arr[makeBestMove()] = ai; //ai makes best move and passes turn to human
      humanTurn=!humanTurn;
      gameEndingCondition();
    }
    //ui materials
    return Material(
      child: Stack(
        children: [
          Container(
              height: double.infinity,
              width: double.infinity,
              child: Image.asset('assets/tt1.jpg',fit: BoxFit.fill,)
          ),
          if(isGameOver)
            Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      child: Text(
                        result,
                        style: TextStyle(color: Colors.purple,fontWeight: FontWeight.bold,fontSize: 40),
                      ),
                    ),
                    SizedBox(height: 30,),
                    RaisedButton(
                      color: Colors.red,
                      child: Text(
                        "back",
                        style: TextStyle(color: Colors.white,fontSize: 20),
                      ),
                      onPressed: ()=>Navigator.of(context).pop(), //pressing back button after game is over will get you to home page
                    )
                  ],
                ),
              ),
            ),
          if(!isGameOver)Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Text(
                      (humanTurn)?human+"'s turn":ai+"'s turn",
                    style: TextStyle(color: (humanTurn)?Colors.red:Colors.indigo,fontWeight: FontWeight.bold,fontSize: 25),
                  ),
                ),
                SizedBox(height: 40,),
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width*0.6,
                    height: MediaQuery.of(context).size.width*0.6,
                    color: Colors.white,
                    child: MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      //xo grid consist of 9 custom cells
                      child: GridView(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                        ),
                        children: [
                          InkWell(
                            child: cell(ap.arr[0]),
                            onTap: () {
                              if(ap.arr[0]==''){
                                setState(() {
                                   if(humanTurn) ap.updateArr(human, 0);
                                   humanTurn=!humanTurn;
                                   print(ap.arr[0]);
                                });
                              }
                            },
                          ),
                          InkWell(
                            child: cell(ap.arr[1]),
                            onTap: () {
                              if(ap.arr[1]==''){
                                setState(() {
                                  if(humanTurn) ap.updateArr(human, 1);
                                  humanTurn=!humanTurn;
                                  print(ap.arr[1]);
                                });
                              }
                            },
                          ),
                          InkWell(
                            child: cell(ap.arr[2]),
                            onTap: () {
                              if(ap.arr[2]==''){
                                setState(() {
                                  if(humanTurn) ap.updateArr(human, 2);
                                  humanTurn=!humanTurn;
                                  print(ap.arr[2]);
                                });
                              }
                            },
                          ),
                          InkWell(
                            child: cell(ap.arr[3]),
                            onTap: () {
                              if(ap.arr[3]==''){
                                setState(() {
                                  if(humanTurn) ap.updateArr(human, 3);
                                  humanTurn=!humanTurn;
                                  print(ap.arr[3]);
                                });
                              }
                            },
                          ),
                          InkWell(
                            child: cell(ap.arr[4]),
                            onTap: () {
                              if(ap.arr[4]==''){
                                setState(() {
                                  if(humanTurn) ap.updateArr(human, 4);
                                  humanTurn=!humanTurn;
                                  print(ap.arr[4]);
                                });
                              }
                            },
                          ),
                          InkWell(
                            child: cell(ap.arr[5]),
                            onTap: () {
                              if(ap.arr[5]==''){
                                setState(() {
                                  if(humanTurn) ap.updateArr(human, 5);
                                  humanTurn=!humanTurn;
                                  print(ap.arr[5]);
                                });
                              }
                            },
                          ),
                          InkWell(
                            child: cell(ap.arr[6]),
                            onTap: () {
                              if(ap.arr[6]==''){
                                setState(() {
                                  if(humanTurn) ap.updateArr(human, 6);
                                  humanTurn=!humanTurn;
                                  print(ap.arr[6]);
                                });
                              }
                            },
                          ),
                          InkWell(
                            child: cell(ap.arr[7]),
                            onTap: () {
                              if(ap.arr[7]==''){
                                setState(() {
                                  if(humanTurn) ap.updateArr(human, 7);
                                  humanTurn=!humanTurn;
                                  print(ap.arr[7]);
                                });
                              }
                            },
                          ),
                          InkWell(
                            child: cell(ap.arr[8]),
                            onTap: () {
                              if(ap.arr[8]==''){
                                setState(() {
                                  if(humanTurn) ap.updateArr(human, 8);
                                  humanTurn=!humanTurn;
                                  print(ap.arr[8]);
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

