import 'package:flutter/material.dart';

class StyleHelper{
  //general
  static Color iconColor = Color(0xff1fd3ae);
  static Color mainColor = Color(0xff1fd3ae);
  /////////

  //flatbutton
  static TextStyle loginFlatButtonTextStyle =
  TextStyle(color: Colors.blue, fontSize: 15);
  static TextStyle loginFlatButtonSeparatorTextStyle =
  TextStyle(color: Colors.black, fontSize: 15);
  static TextStyle detailsButtonTextStyle =
  TextStyle(color: StyleHelper.mainColor, fontSize: 15);//show details flatbutton
  ///////////////////////////////

  //promary raisedbutton
  static double raisedButtonHeight=48;
  ////////////////////////////

  //primary container
  static EdgeInsetsGeometry primaryContainerMargin=EdgeInsets.all(10);
  static EdgeInsetsGeometry primaryContainerPadding=EdgeInsets.all(10);
  ////////

  //message
  static TextStyle messageTextStyle=TextStyle(fontSize: 16,fontWeight: FontWeight.normal,
      color: Colors.black,
      decoration: TextDecoration.none);
  /////////


}