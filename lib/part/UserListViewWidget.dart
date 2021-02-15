
import 'package:flutter/material.dart';
import 'package:test_roketan/part/DataBase.dart';

import 'package:test_roketan/part/DataManager.dart';
import 'package:test_roketan/part/Defines.dart' as Defines;
import 'package:test_roketan/view/MainView.dart';



class UserListViewWidget extends StatelessWidget {
  final List<Map<String, dynamic>> userDataList;
  final Function keepRelease;
  final Function onTapUserToProfilePage;
  UserListViewWidget({
    this.userDataList,
    this.keepRelease,
    this.onTapUserToProfilePage,
  });

  //データマネージャのインスタンス生成
  ViewDataManager _vdm = new ViewDataManager();
  ActiveAccountDataManager _aadm = new ActiveAccountDataManager();

  _isKeep( int index ) async{
    var _userIDList;
    var _userInfoList;

    _userIDList = await _aadm.getAccountData('keepUserInfoList');
    _userInfoList = await DataBase().getDBUserDataListFromUserIDList( _userIDList );

    for( int i=0; i<_userInfoList.length; i++ ){
      if( userDataList[ index ]['id'] == _userInfoList[i]['id'] ){
        return true;
      }
    }
    return false;
  }

  _onTapUserToProfilePage( int userIndex ){
    var _userInfo = userDataList[ userIndex ];

    //ログ保存用
    DataBase().addOperationLog( 'to profile page ${_userInfo['id']}' );

    _vdm.setViewData('selectedUserInfo', _userInfo);
    onTapUserToProfilePage(SubPageName.Profile.index);
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        itemBuilder: (BuildContext context, int userIndex) {
          return Column(
            children: [
              Container(
                child: Row(
                  children: [
                    SizedBox( width: 10 ),
                    GestureDetector(
                      onTap: () => _onTapUserToProfilePage(userIndex),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        backgroundImage: userDataList[ userIndex ]['profileIcon'] == ''
                            ? Image.network( 'assets/noimage.png' ).image
                            : Image.network( userDataList[ userIndex ]['profileIcon'] ).image,
                      ),
                    ),
                    SizedBox( width: 10 ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _onTapUserToProfilePage(userIndex),
                        child: Container(
                          height: 50.0,
                          alignment: Alignment.centerLeft,
                          child: RichText(
                            text: TextSpan(
                              text: userDataList[ userIndex ]['nickname'],
                              style: TextStyle(
                                color: Defines.colorset['darkdrawcolor'],
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    FutureBuilder(
                        future: _isKeep( userIndex ),
                        builder: (context, snapshot) {
                          return !snapshot.hasData ? Container() : Container(
                            alignment: Alignment.topRight,
                            width: 120.0,
                            height: 50.0,
                            child: Center(
                              child: RaisedButton(
                                color: snapshot.data
                                    ? Defines.colorset['keepusercolor']
                                    : Defines.colorset['backgroundcolor'],
                                child: Text(
                                  snapshot.data ? '保存済み' : 'リストに追加',
                                  style: TextStyle(
                                    color: snapshot.data
                                        ? Colors.white
                                        : Defines.colorset['drawcolor'],
                                    fontWeight: snapshot.data
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: 12,
                                  ),
                                ),
                                shape: StadiumBorder(
                                  side: BorderSide(
                                    color: snapshot.data
                                        ? Defines.colorset['keepusercolor']
                                        : Defines.colorset['drawcolor'],
                                  ),
                                ),
                                onPressed: () => keepRelease(userIndex),
                              ),
                            ),
                          );
                        }
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(right: 36.0),
                child: Row(
                  children: [
                    Container(
                      width: 50.0,
                    ),
                    Flexible(
                      child: GestureDetector(
                        onTap: () => _onTapUserToProfilePage(userIndex),
                        child: RichText(
                          text: TextSpan(
                            text: userDataList[ userIndex ]['introduction'],
                            style: TextStyle(
                                color: Defines.colorset['darkdrawcolor'],
                                fontSize: 14.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 6.0,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Defines.colorset['drawcolor']),
                  ),
                ),
              ),
            ],
          );
        },
        itemCount: userDataList != null ? userDataList.length : 0,
      ),
    );
  }
}
