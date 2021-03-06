import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rahbaran/bloc/error_bloc.dart';
import 'package:rahbaran/data_model/token_model.dart';
import 'package:rahbaran/data_model/user_model.dart';
import 'package:rahbaran/repository/database_helper.dart';
import 'package:rahbaran/repository/token_repository.dart';
import 'package:rahbaran/theme/style_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' as convert;
import 'base_state.dart';
import 'freighter.dart';
import 'login.dart';
import 'news.dart';

abstract class BaseAuthorizedState<T extends StatefulWidget>
    extends BaseState<T> {
  String token;
  UserModel currentUser;
  int bottomNavigationSelectedIndex;
  //bool isActiveBottomNavigation=true;

  BaseAuthorizedState([this.bottomNavigationSelectedIndex]) ;

  getToken() async {
    try {
      SharedPreferences sharedPreferences = await SharedPreferences
          .getInstance();
      token = sharedPreferences.getString('token');
    }on Exception catch (e) {
      //to do (log)
    }finally{
      if (token == null) {
        Navigator.of(context).pushNamedAndRemoveUntil(Login.routeName,
                (Route<dynamic> rout) => false);
      }
    }
  }

  void logout() {
    SharedPreferences.getInstance().then((SharedPreferences val) {
      val.clear();

      //save token to db
      DatabaseHelper().database.then((db){
        TokenRepository(db).deleteAll().then((val){
          Navigator.of(context).pushNamedAndRemoveUntil(Login.routeName,
                  (Route<dynamic> rout) => false);
        });
      });
    });
  }

  initCurrentUser() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var currentUserJson=sharedPreferences.getString('currentUser');
    if(currentUserJson==null) {
      var url = 'https://apimy.rmto.ir/api/Hambar/getuserinfo';
      var response = await getApiData(url, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response != null) {
        var jsonResponse = convert.jsonDecode(response.body);
        if (jsonResponse['message']['code'] == 0) {
          currentUser = UserModel.fromJson(jsonResponse['data']);
          sharedPreferences.setString('currentUser', currentUser.toJson());
        } else {
          errorBloc.add(ShowErrorEvent('خطا در ارتباط با سرور'));
        }
      }
    }else {
      currentUser = UserModel.fromJson(convert.jsonDecode(currentUserJson));
    }
  }

  setCurrentUser(UserModel user) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('currentUser', user.toJson());
    currentUser=user;
  }
}
