import 'package:flutter/material.dart';
import 'package:test_roketan/part/DataBase.dart';
import 'package:test_roketan/part/Defines.dart' as Defines;
import 'package:test_roketan/part/DataManager.dart';
import 'package:test_roketan/part/UserListViewWidget.dart';
import 'package:test_roketan/view/MainView.dart';

class KeepUser extends StatefulWidget {
  final Function onTapToSubPage;
  KeepUser({
    this.onTapToSubPage,
  });


  @override
  _KeepUserState createState() => _KeepUserState();
}

class _KeepUserState extends State<KeepUser> {


  ////データマネージャのインスタンス作成
  ActiveAccountDataManager _aadm = new ActiveAccountDataManager();


  final String _keepuser = '保存済み';

  List<dynamic> _keepUserIDList;
  List<Map<String, dynamic>> _keepUserInfoList;


  //データベースからデータを引っ張ってくる処理
  _getData() async{
    _keepUserIDList = await _aadm.getAccountData('keepUserInfoList');
    _keepUserInfoList = await DataBase().getDBUserDataListFromUserIDList( _keepUserIDList );
  }


  void _keepRelease( int index ) {
    //ユーザーをリストに保存したりリストから保存解除するときの処理
    setState(() {
      _keepUserInfoList.removeAt( index );
      _keepUserIDList.removeAt( index );
      _aadm.setAccountData('keepUserInfoList', _keepUserIDList);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getData(),
      builder: (context, snapshot) {
        return snapshot.hasData ? Container() : Column(
          children: [
            Container(
              height: 60.0,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Defines.colorset['keepusercolor'],
                    width: 5.0,
                  ),
                ),
                color: Defines.colorset['backgroundcolor'],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 100.0,
                    child: Row(
                      children: [
                        Icon(
                          Icons.people_outlined,
                          color: Defines.colorset['darkdrawcolor'],
                        ),
                        RichText(
                          text: TextSpan(
                            text: _keepuser,
                            style: TextStyle(
                              color: Defines.colorset['darkdrawcolor'],
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: Center(
                      child: Text(
                        _keepUserInfoList == null ? '0' : _keepUserInfoList.length.toString(),
                        style: TextStyle(
                          color: Defines.colorset['darkdrawcolor'],
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: UserListViewWidget(
                userDataList: _keepUserInfoList,
                keepRelease: (int index) => _keepRelease(index),
                onTapUserToProfilePage: (int index) => widget.onTapToSubPage(index),
              )
            ),
          ],
        );
      }
    );
  }
}
