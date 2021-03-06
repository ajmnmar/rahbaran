import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rahbaran/Widget/logo_header.dart';
import 'package:rahbaran/Widget/message.dart';
import 'package:rahbaran/Widget/primary_validation.dart';
import 'package:rahbaran/bloc/loading_bloc.dart';
import 'package:rahbaran/bloc/validation_bloc.dart';
import 'package:rahbaran/common/mobile_mask.dart';
import 'package:rahbaran/page/argument/register_step1_argument.dart';
import 'package:rahbaran/page/register_step1.dart';
import '../common/national_code.dart';
import '../theme/style_helper.dart';
import 'base_state.dart';
import 'dart:convert' as convert;

class PreRegister extends StatefulWidget {
  static const routeName = '/PreRegister';

  @override
  PreRegisterState createState() => PreRegisterState();
}

class PreRegisterState extends BaseState<PreRegister> {
  //controllers
  TextEditingController nationalCodeController = new TextEditingController();
  TextEditingController mobileController = new TextEditingController();

  //variables
  ValidationBloc validationBloc = new ValidationBloc();
  LoadingBloc loadingBloc = new LoadingBloc();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
          appBar: AppBar(
            title: Text('ثبت نام', style: Theme.of(context).textTheme.title),
            centerTitle: true,
            elevation: 2,
            automaticallyImplyLeading: false,
            actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () {
                    Navigator.of(context).pop();
                  })
            ],
          ),
          body: Container(
            alignment: Alignment.center,
            child: ListView(
              children: <Widget>[
                LogoHeader(),
                registerSection()
              ],
            ),
          ),
        ),
        Message(errorBloc),
      ],
    );
  }

  Widget registerSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      margin: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            child: TextField(
                controller: nationalCodeController,
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
            child: Container(
              alignment: Alignment.center,
              child: TextField(
                controller: mobileController,
                keyboardType: TextInputType.phone,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.caption,
                decoration: InputDecoration(
                    hintText: 'شماره موبایل',
                    contentPadding: EdgeInsets.all(7),
                    prefixIcon: Icon(
                      Icons.phone,
                      color: StyleHelper.iconColor,
                    ),
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
                        registerButtonClicked();
                      },
                      child: state.isLoading? CircularProgressIndicator(
                          valueColor:
                          new AlwaysStoppedAnimation<Color>(Colors.white)):
                      Text('تایید و ادامه', style: Theme.of(context).textTheme.button));
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

  void registerButtonClicked() async {
    try {
      validationBloc.add(HideValidationEvent());
      if (nationalCodeController.text.isEmpty) {
        validationBloc.add(ShowValidationEvent('لطفا شماره ملی خود را وارد کنید'));
        return;
      } else if (mobileController.text.isEmpty) {
        validationBloc.add(ShowValidationEvent('لطفا شماره موبایل خود را وارد کنید'));
        return;
      } else if (NationalCode.checkNationalCode(nationalCodeController.text) ==
          false) {
        validationBloc.add(ShowValidationEvent('فرمت شماره ملی اشتباره است'));
        return;
      }
      loadingBloc.add(LoadingEvent.show);

      var url =
          'https://apimy.rmto.ir/api/Hambar/PreRegistration?nationalCode=${nationalCodeController.text}&mobileNumber=${mobileController.text}';
      var response = await getApiData(url);
      if (response != null) {
        var jsonResponse = convert.jsonDecode(response.body);
        if (jsonResponse['message']['code'] == 0) {
          setState(() {
            Navigator.of(context).pushReplacementNamed(RegisterStep1.routeName,
              arguments: RegisterStep1Argument(jsonResponse['data']));
          });
        } else if (jsonResponse['message']['code'] == 1) {
          validationBloc.add(ShowValidationEvent('برای این کاربر شماره موبایل ثبت نشده است'));
        } else if (jsonResponse['message']['code'] == 2) {
          validationBloc.add(ShowValidationEvent('کاربری با این مشخصات پیدا نشد'));
        } else if (jsonResponse['message']['code'] == 3) {
          validationBloc.add(ShowValidationEvent('شما با شماره موبایل ${MobileMask.changeMobileMaskDirection(jsonResponse['data'])} در سامانه مرکزی ثبت نام کرده اید'));
        } else if (jsonResponse['message']['code'] == 4) {
          validationBloc.add(ShowValidationEvent('کاربر با این مشخصات پیشتر ثبت نام کرده است'));
        } else {
          validationBloc.add(ShowValidationEvent('خطا در ارتباط با سرور'));
        }
      }
    } finally {
      loadingBloc.add(LoadingEvent.hide);
    }
  }
}
