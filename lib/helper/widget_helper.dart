import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rahbaran/data_model/user_model.dart';
import 'package:rahbaran/helper/style_helper.dart';


class WidgetHelper {
  static Widget messageSection(double messageOpacity, double containerTop,
      String message, [bool messageVisibility, onEnd]) {
    return Visibility(
        visible: messageVisibility,
        child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
                width: double.infinity,
                child: AnimatedOpacity(
                  opacity: messageOpacity,
                  duration: Duration(milliseconds: 1500),
                  onEnd: onEnd,
                  child: Container(
                    margin: EdgeInsets.only(top: containerTop),
                    height: 55,
                    color: Colors.red,
                    alignment: Alignment.center,
                    child: Text(message, style: StyleHelper.messageTextStyle),
                  ),
                ))));
  }

  static Widget logoHeaderSection(double width, [double topPadding]) {
    return Container(
      padding: EdgeInsets.only(left: 30,
          right: 30,
          top: topPadding == null ? 0 : topPadding,
          bottom: 0),
      child: Image.asset(
        "assets/images/logo.png",
        width: width / 3,
      ),
    );
  }
}
