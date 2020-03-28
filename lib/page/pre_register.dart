import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:rahbaran/common/mobile_mask.dart';
import 'package:rahbaran/page/register_step1.dart';

import '../common/national_code.dart';
import '../helper/style_helper.dart';
import '../helper/widget_helper.dart';
import 'validation_base_state.dart';
import 'dart:convert' as convert;

class PreRegister extends StatefulWidget {
  @override
  PreRegisterState createState() => PreRegisterState();
}

class PreRegisterState extends ValidationBaseState<PreRegister> {
  //controllers
  TextEditingController nationalCodeController = new TextEditingController();
  TextEditingController mobileController = new TextEditingController();

  //variables
  bool isLoading = false;
  GlobalKey nationalTextFieldKey = GlobalKey();
  double nationalTextFieldHeight;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {
        nationalTextFieldHeight =
            nationalTextFieldKey.currentContext.size.height;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
          appBar: AppBar(
            title: Text('ثبت نام', style: StyleHelper.appBarTitleTextStyle),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                WidgetHelper.logoHeaderSection(
                    MediaQuery.of(context).size.width),
                registerSection()
              ],
            ),
          ),
        ),
        WidgetHelper.messageSection(
            messageOpacity, MediaQuery.of(context).padding.top, message,messageVisibility,(){
          setState(() {
            messageVisibility= messageOpacity==0?false:true;
          });
        })
      ],
    );
  }

  Widget registerSection() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30),
        margin: EdgeInsets.symmetric(vertical: 20),
        child: ListView(
          children: <Widget>[
            SizedBox(
              width: double.infinity,
              child: TextField(
                  key: nationalTextFieldKey,
                  controller: nationalCodeController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                      hintText: 'شماره ملی',
                      contentPadding: EdgeInsets.all(7),
                      prefixIcon: Icon(
                        Icons.person,
                        color: StyleHelper.iconColor,
                      ),
                      border: StyleHelper.textFieldBorder)),
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
                  decoration: InputDecoration(
                      hintText: 'شماره موبایل',
                      contentPadding: EdgeInsets.all(7),
                      prefixIcon: Icon(
                        Icons.phone,
                        color: StyleHelper.iconColor,
                      ),
                      border: StyleHelper.textFieldBorder),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            SizedBox(
              width: double.infinity,
              height: nationalTextFieldHeight,
              child: RaisedButton(
                onPressed: () {
                  if (isLoading) return;
                  registerButtonClicked();
                },
                color: StyleHelper.mainColor,
                shape: StyleHelper.buttonRoundedRectangleBorder,
                child: isLoading
                    ? CircularProgressIndicator(
                        valueColor:
                            new AlwaysStoppedAnimation<Color>(Colors.white))
                    : Text('تایید و ادامه', style: StyleHelper.buttonTextStyle),
              ),
            ),
            Visibility(
              visible: validationVisibility,
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(top: 10),
                child: Text(
                  validationMessage,
                  style: StyleHelper.validationTextStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void registerButtonClicked() async {
    try {
      hideValidation();
      if (nationalCodeController.text.isEmpty) {
        showValidation('لطفا شماره ملی خود را وارد کنید');
        return;
      } else if (mobileController.text.isEmpty) {
        showValidation('لطفا شماره موبایل خود را وارد کنید');
        return;
      } else if (NationalCode.checkNationalCode(nationalCodeController.text) ==
          false) {
        showValidation('فرمت شماره ملی اشتباره است');
        return;
      }
      setState(() {
        isLoading = true;
      });

      var url =
          'https://apimy.rmto.ir/api/Hambar/PreRegistration?nationalCode=${nationalCodeController.text}&mobileNumber=${mobileController.text}';
      var response = await getApiData(url);
      if (response != null) {
        var jsonResponse = convert.jsonDecode(response.body);
        if (jsonResponse['message']['code'] == 0) {
          setState(() {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) =>
                    RegisterStep1(jsonResponse['data'])));
          });
        } else if (jsonResponse['message']['code'] == 1) {
          showValidation('برای این کاربر شماره موبایل ثبت نشده است');
        } else if (jsonResponse['message']['code'] == 2) {
          showValidation('کاربری با این مشخصات پیدا نشد');
        } else if (jsonResponse['message']['code'] == 3) {
          showValidation(
              'شما با شماره موبایل ${MobileMask.changeMobileMaskDirection(jsonResponse['data'])} در سامانه مرکزی ثبت نام کرده اید');
        } else if (jsonResponse['message']['code'] == 4) {
          showValidation('کاربر با این مشخصات پیشتر ثبت نام کرده است');
        } else {
          showValidation('خطا در ارتباط با سرور');
        }
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
