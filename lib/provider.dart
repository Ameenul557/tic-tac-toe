import 'package:flutter/material.dart';

//change notifier notify the widgets that listening to them
class ArrayProvider with ChangeNotifier{
  List<String> arr = ['','','','','','','','','']; //empty cells

  void updateArr(String c,int i){
    arr[i] = c;
    notifyListeners(); //whenever a cell is updated by ai/human the ui is updated to see that changes
  }
}