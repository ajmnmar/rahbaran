import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rahbaran/Widget/logo_header.dart';
import 'package:rahbaran/Widget/message.dart';
import 'package:rahbaran/Widget/primary_validation.dart';
import 'package:rahbaran/bloc/loading_bloc.dart';
import 'package:rahbaran/bloc/validation_bloc.dart';
import 'package:rahbaran/common/national_code.dart';
import 'package:rahbaran/data_model/token_model.dart';
import 'package:rahbaran/page/login_rule.dart';
import 'package:rahbaran/repository/database_helper.dart';
import 'package:rahbaran/repository/token_repository.dart';
import 'package:rahbaran/theme/style_helper.dart';
import 'package:rahbaran/page/news.dart';
import 'package:rahbaran/page/pre_forget_password.dart';
import 'package:rahbaran/page/pre_register.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' as convert;
import 'base_state.dart';

class Login extends StatefulWidget {
  static const routeName = '/Login';

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return LoginState();
  }
}

class LoginState extends BaseState<Login> {
  //controllers
  TextEditingController usernameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  //variables
  ValidationBloc validationBloc = new ValidationBloc();
  LoadingBloc loadingBloc = new LoadingBloc();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Stack(
      children: <Widget>[
        Scaffold(
          body: Container(
            alignment: Alignment.topCenter,
            child: ListView(
              children: <Widget>[
                LogoHeader(40),
                loginSection(),
                alternativeSection()
              ],
            ),
          ),
        ),
        Message(errorBloc),      ],
    );
  }

  Widget loginSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            child: TextField(
                controller: usernameController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.caption,
                decoration: InputDecoration(
                  hintText: 'شماره ملی',
                  contentPadding: EdgeInsets.all(7),
                  prefixIcon: Icon(
                    Icons.person,
                    color: StyleHelper.iconColor,
                  ),
                )),
          ),
          SizedBox(
            height: 10,
          ),
          SizedBox(
            width: double.infinity,
            child: TextField(
              controller: passwordController,
              keyboardType: TextInputType.text,
              obscureText: true,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.caption,
              decoration: InputDecoration(
                hintText: 'کلمه عبور',
                contentPadding: EdgeInsets.all(7),
                prefixIcon: Icon(
                  Icons.vpn_key,
                  color: StyleHelper.iconColor,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          SizedBox(
            width: double.infinity,
            height: StyleHelper.raisedButtonHeight,
            child: BlocBuilder(
                bloc:loadingBloc,
                builder: (context,LoadingState state){
                  return RaisedButton(
                      onPressed: () {
                        if (state.isLoading) return;
                        loginButtonClicked();
                      },
                      child: state.isLoading? CircularProgressIndicator(
                          valueColor:
                          new AlwaysStoppedAnimation<Color>(Colors.white)):
                      Text('ورود', style: Theme.of(context).textTheme.button));
                }
            ),
          ),
          BlocBuilder(
              bloc: validationBloc,
              builder: (context, ValidationState state) {
                return PrimaryValidation(state.validationVisibility,state.validationMessage);
              }),
        ],
      ),
    );
  }

  Widget alternativeSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 4,
            child: FlatButton(
                padding: EdgeInsets.all(0),
                onPressed: () {
                  loginHelpClicked();
                },
                child: Text(
                  'قوانین ومقررات',
                  textAlign: TextAlign.center,
                  style: StyleHelper.loginFlatButtonTextStyle,
                )),
          ),
          Text('/',textAlign: TextAlign.center,
            style: StyleHelper.loginFlatButtonSeparatorTextStyle,),
          Expanded(
            flex: 4,
            child: FlatButton(
                //materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.all(0),
                onPressed: () {
                  forgetPasswordClicked();
                },
                child: Text(
                  'فراموشی رمزعبور',
                  textAlign: TextAlign.center,
                  style: StyleHelper.loginFlatButtonTextStyle,
                )),
          ),
          Text('/',textAlign: TextAlign.center,
            style: StyleHelper.loginFlatButtonSeparatorTextStyle,),
          Expanded(
            flex: 5,
            child: FlatButton(
                padding: EdgeInsets.all(0),
                onPressed: () {
                  registerClicked();
                },
                child: Text('ثبت نام در سامانه',
                    textAlign: TextAlign.center,
                    style: StyleHelper.loginFlatButtonTextStyle)
            ),
          )
        ],
      ),
    );
  }

  void signIn(String username, String password) async {
    try {
      SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();
      var url =
          'https://apimy.rmto.ir/api/Hambar/Authenticate?username=$username&password=$password';
      var response = await getApiData(url);
      if (response != null) {
        var jsonResponse = convert.jsonDecode(response.body);
        if (jsonResponse['message']['code'] == 0) {
          sharedPreferences.setString('token', jsonResponse['data']['token']);

          //save token to db
          var db=await DatabaseHelper().database;
          await TokenRepository(db).deleteAll();
          await TokenRepository(db).save(TokenModel(jsonResponse['data']['token'], ''));

          Navigator.of(context).pushNamedAndRemoveUntil(News.routeName,
                  (Route<dynamic> rout) => false);
        } else if (jsonResponse['message']['code'] == 6) {
          validationBloc.add(ShowValidationEvent('نام کاربری یا رمز عبور اشتباه است'));
        }
      }
    } finally {
      loadingBloc.add(LoadingEvent.hide);
    }
  }

  void loginButtonClicked() async {
    validationBloc.add(HideValidationEvent());
    if (usernameController.text.isEmpty) {
      validationBloc.add(ShowValidationEvent('لطفا شماره ملی خود را وارد کنید'));
      return;
    } else if (passwordController.text.isEmpty) {
      validationBloc.add(ShowValidationEvent('لطفا رمز عبور خود را وارد کنید'));
      return;
    } else if (NationalCode.checkNationalCode(usernameController.text) ==
        false) {
      validationBloc.add(ShowValidationEvent('فرمت شماره ملی اشتباره است'));
      return;
    }
    loadingBloc.add(LoadingEvent.show);

    signIn(usernameController.text, passwordController.text);
  }

  void forgetPasswordClicked() {
    Navigator.of(context).pushNamed(PreForgetPassword.routeName);
  }

  void registerClicked() {
    Navigator.of(context).pushNamed(PreRegister.routeName);
  }

  void loginHelpClicked() {
    Navigator.of(context).pushNamed(LoginRule.routeName);
  }
}
