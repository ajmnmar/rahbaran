import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rahbaran/Widget/grid_cell.dart';
import 'package:rahbaran/Widget/main_bottom_navigation_bar.dart';
import 'package:rahbaran/Widget/message.dart';
import 'package:rahbaran/Widget/primary_drawer.dart';
import 'package:rahbaran/bloc/error_bloc.dart';
import 'package:rahbaran/bloc/loading_bloc.dart';
import 'package:rahbaran/data_model/shipping_document_model.dart';
import 'package:rahbaran/page/argument/shipping_document_details_argument.dart';
import 'package:rahbaran/page/base_authorized_state.dart';
import 'package:rahbaran/page/shipping_document_details.dart';
import 'dart:convert' as convert;

import 'package:rahbaran/theme/style_helper.dart';

class ShippingDocument extends StatefulWidget {
  static const routeName = '/ShippingDocument';

  @override
  ShippingDocumentState createState() => ShippingDocumentState();
}

class ShippingDocumentState extends BaseAuthorizedState<ShippingDocument> {
  //variables
  List<ShippingDocumentModel> shippingDocumentList;
  LoadingBloc loadingBloc = new LoadingBloc();

  ShippingDocumentState():super(2);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    loadingBloc.add(LoadingEvent.show);
    getToken().then((val) {
      getShippingDocument().then((list) {
        setState(() {
          shippingDocumentList = list;
          loadingBloc.add(LoadingEvent.hide);
        });
      });
      initCurrentUser().then((val) {
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
          appBar: AppBar(
            title: Text('لیست اسناد حمل',style: Theme.of(context).textTheme.title),
            centerTitle: true,
            elevation: 2,
          ),
          drawer: PrimaryDrawer(currentUser: currentUser,logout: logout,),
          body: BlocBuilder(
              bloc: loadingBloc,
              builder: (context, LoadingState state) {
                return shippingDocumentListBody(state);
              }),
          bottomNavigationBar: MainBottomNavigationBar(bottomNavigationSelectedIndex),
        ),
        Message(errorBloc),
      ],
    );
  }

  Widget shippingDocumentListBody(LoadingState state) {
    if (state.isLoading) {
      return Center(
          child: CircularProgressIndicator(
              valueColor:
              new AlwaysStoppedAnimation<Color>(StyleHelper.mainColor)));
    } else {
      if (shippingDocumentList == null || shippingDocumentList.length == 0) {
        return Center(
          child: Text(
            'سندحمل برای شما یافت نشد!',
            style: Theme.of(context).textTheme.display2,
          ),
        );
      } else {
        return ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            if(shippingDocumentList[index].docTypeString.toLowerCase()=='passenger')
              return passengerShippingDocumentCard(shippingDocumentList[index]);
            else
              return otherShippingDocumentCard(shippingDocumentList[index]);
          },
          itemCount: shippingDocumentList.length,
        );
      }
    }
  }

  Widget otherShippingDocumentCard(ShippingDocumentModel shippingDocument) {
    return Card(
        margin: EdgeInsets.all(10),
        child: GestureDetector(
          onTap: (){
            Navigator.of(context).pushNamed(ShippingDocumentDetails.routeName,
              arguments: ShippingDocumentDetailsArgument(shippingDocument));
          },
          child: ClipPath(
            clipper: ShapeBorderClipper(shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3))),
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border(right: BorderSide(color: StyleHelper.mainColor, width: 5))),
              child: Column(
                children: <Widget>[
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        TertiaryGridCell('شرح کالا:'),
                        TertiaryGridCell(shippingDocument.goodTitle),
                      ],
                    ),
                  ),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        TertiaryGridCell('نوع سند:'),
                        TertiaryGridCell(shippingDocument.docTypeStr),
                      ],
                    ),
                  ),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        TertiaryGridCell('تاریخ صدور:'),
                        TertiaryGridCell(shippingDocument.issueDate),
                      ],
                    ),
                  ),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        TertiaryGridCell('مسیر:'),
                        TertiaryGridCell(shippingDocument.source+' - '+shippingDocument.destination),
                      ],
                    ),
                  ),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        TertiaryGridCell('سریال بارنامه:'),
                        TertiaryGridCell(shippingDocument.serial),
                      ],
                    ),
                  ),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        TertiaryGridCell('کرایه:'),
                        TertiaryGridCell(shippingDocument.costS),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget passengerShippingDocumentCard(ShippingDocumentModel shippingDocument) {
    return Card(
        margin: EdgeInsets.all(10),
        child: GestureDetector(
          onTap: (){
            Navigator.of(context).pushNamed(ShippingDocumentDetails.routeName,
                arguments: ShippingDocumentDetailsArgument(shippingDocument));
          },
          child: ClipPath(
            clipper: ShapeBorderClipper(shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3))),
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border(right: BorderSide(color: StyleHelper.mainColor, width: 5))),
              child: Column(
                children: <Widget>[
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        TertiaryGridCell('نوع سند:'),
                        TertiaryGridCell(shippingDocument.docTypeStr),
                      ],
                    ),
                  ),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        TertiaryGridCell('تاریخ صدور:'),
                        TertiaryGridCell(shippingDocument.issueDate),
                      ],
                    ),
                  ),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        TertiaryGridCell('مسیر:'),
                        TertiaryGridCell(shippingDocument.source+' - '+shippingDocument.destination),
                      ],
                    ),
                  ),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        TertiaryGridCell('شماره صورت وضعیت:'),
                        TertiaryGridCell(shippingDocument.serial),
                      ],
                    ),
                  ),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        TertiaryGridCell('کرایه:'),
                        TertiaryGridCell(shippingDocument.costS),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  getShippingDocument() async {
    var url = 'https://apimy.rmto.ir/api/Hambar/getshippingdocument';
    var response = await postApiData(url, headers: {
      'Authorization': 'Bearer $token',
      "Content-Type": "application/json"
    },body: convert.json.encode({}));

    if (response != null) {
      var jsonResponse = convert.jsonDecode(response.body);
      if (jsonResponse['message']['code'] == 0) {
        var shippingDocumentJsonList = jsonResponse['data'] as List;
        return shippingDocumentJsonList
            .map((shippingDocumentJson) => ShippingDocumentModel.fromJson(shippingDocumentJson))
            .toList();
      } else {
        errorBloc.add(ShowErrorEvent('خطا در ارتباط با سرور'));
      }
    }
  }
}
