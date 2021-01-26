
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:test_roketan/part/DataBase.dart';
import 'package:test_roketan/part/DataManager.dart';

import 'package:test_roketan/part/Defines.dart' as Defines;
import 'package:test_roketan/part/Hashtag.dart';
import 'package:test_roketan/part/PostListViewWidget.dart';
import 'package:test_roketan/view/MainView.dart';
import 'package:url_launcher/url_launcher.dart';


class Profile extends StatefulWidget {
  final userData;
  final Function onTapToSubPage;
  Profile({
    this.userData,
    this.onTapToSubPage
  });


  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  //データマネージャのインスタンス生成
  ActiveAccountDataManager _aadm = new ActiveAccountDataManager();


  static double avatarMaximumRadius = 40.0;
  static double avatarMinimumRadius = 20.0;
  double _avatarRadius = avatarMaximumRadius;
  double _expandedHeaderHeight = 130.0;
  double translate = -avatarMaximumRadius;
  bool _isExpanded = true;
  double _offset = 0.0;

  int _postNumber;


  bool _isKeep(){
    var _userIDList;

    _userIDList = _aadm.getAccountData('keepUserInfoList');

    for( int i=0; i<_userIDList.length; i++ ){
      if( widget.userData['id'] == _userIDList[i] ){
        return true;
      }
    }
    return false;
  }


  bool _isMyAccount(){
    if( widget.userData['id'] == _aadm.getAccountData('id') ){
      return true;
    }
    if( widget.userData['id'] != _aadm.getAccountData('id') ){
      return false;
    }
  }

  _keepRelease(){
    var _userIDList;
    var _userInfoList;

    _userIDList = _aadm.getAccountData('keepUserInfoList');


    //ユーザーをリストに保存したりリストから保存解除するときの処理を書く
    for( int i=0; i<_userIDList.length; i++ ){
      //ボタンを押した対象のユーザーが、自分の保存リストに含まれていたら保存リストから削除する
      if( widget.userData['id'] == _userIDList[i] ){
        setState(() {
          _userIDList.removeAt(i);
          _aadm.setAccountData('keepUserInfoList', _userIDList);
        });
        return null;
      }
    }
    //ボタンを押した対象のユーザーが、自分の保存リストに含まれていなかったら、保存リストに追加する。
    setState(() {
      _userIDList.insert(0, widget.userData['id'] );
      _aadm.setAccountData('keepUserInfoList', _userIDList);
    });
  }


  Future<List<String>>_createInputHashtagList( List _hashtagIDList ) async{
    List<String> _list = [];
    List<Map<String, dynamic>> _temp = await DataBase().getDBHashtagDataListFromHashtagIDList( _hashtagIDList );

    for( int i=0; i<_temp.length; i++ ){
      if( _temp[i] != null ){
        _list.add( _temp[i]['hashtag'] );
      }
    }
    return _list;
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      color: Defines.colorset['backgroundcolor'],
      child: NotificationListener<ScrollUpdateNotification>(
        onNotification: (scrollNotification){
          final pixels = scrollNotification.metrics.pixels;

          // check if scroll is vertical ( left to right OR right to left)
          final scrollTabs = (scrollNotification.metrics.axisDirection ==
              AxisDirection.right ||
              scrollNotification.metrics.axisDirection == AxisDirection.left);

          if (!scrollTabs) {
            // and here prevents animation of avatar when you scroll tabs
            if (_expandedHeaderHeight - pixels <= kToolbarHeight) {
              if (_isExpanded) {
                translate = 0.0;
                setState(() {
                  _isExpanded = false;
                });
              }
            } else {
              translate = -avatarMaximumRadius + pixels;
              if (translate > 0) {
                translate = 0.0;
              }
              if (!_isExpanded) {
                setState(() {
                  _isExpanded = true;
                });
              }
            }

            _offset = pixels * 0.4;

            final newSize = (avatarMaximumRadius - _offset);

            setState(() {
              if (newSize < avatarMinimumRadius) {
                _avatarRadius = avatarMinimumRadius;
              } else if (newSize > avatarMaximumRadius) {
                _avatarRadius = avatarMaximumRadius;
              } else {
                _avatarRadius = newSize;
              }
            });
          }
          return false;
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              floating: false,
              elevation: 0.0,
              pinned: true,
              expandedHeight: _expandedHeaderHeight,
              backgroundColor: Defines.colorset['backgroundcolor'],
              leading: _isExpanded
                  ? null
                  : CircleAvatar(
                      radius: 40,
                      backgroundImage: Image.network( widget.userData['profileIcon'] ).image,
                    ),
              title: _isExpanded
                  ? null
                  : RichText(
                      maxLines: 1,
                      text: TextSpan(
                      text: widget.userData['nickname'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Defines.colorset['darkdrawcolor']),
                      ),
                      overflow: TextOverflow.ellipsis,
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  margin: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: Image.network( widget.userData['profileIcon'] ).image,
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 10),
                          height: 60,
                          alignment: Alignment.centerLeft,
                          child: RichText(
                            maxLines: 1,
                            text: TextSpan(
                              text: widget.userData['nickname'],
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                  color: Defines.colorset['darkdrawcolor']),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Container(
                        child: _isMyAccount()
                            ? _editButton(
                                onPressEditButton: (){

                                  //操作ログ用
                                  DataBase().addOperationLog( 'profile edit' );

                                  widget.onTapToSubPage(SubPageName.EditProfile.index);
                                },
                              )
                            : _keepReleaseButton(
                                isKeep: _isKeep(),
                                onPressKeepReleaseButton:() => _keepRelease(),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Container(
                    margin: EdgeInsets.only(left: 20, right: 20),
                    width: double.infinity,
                    child: SelectableLinkify(
                      onOpen: (link) async {
                        if (await canLaunch(link.url)) {
                          await launch(link.url);
                        } else {
                          throw 'Could not launch $link';
                        }
                      },
                      text: widget.userData['introduction'],
                      style: TextStyle(
                          height: 1.0,
                          color: Defines.colorset['darkdrawcolor'],
                          fontSize: 14.0
                      ),
                      linkStyle: TextStyle(color: Colors.blueAccent),
                    ),
                    /*
                    child: RichText(
                      text: TextSpan(
                        text: widget.userData['introduction'],
                        style: TextStyle(
                            color: Defines.colorset['darkdrawcolor'],
                            fontSize: 12.0),
                      ),
                    ),
                    */
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      padding: EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
                      width: double.infinity,
                      color: Defines.colorset['backgroundcolor'],
                      child: FutureBuilder(
                        future: _createInputHashtagList( widget.userData['profileHashtagList'] ),
                        builder: (context, snapshot) {
                          return !snapshot.hasData ? Container() : Wrap(
                            children: hashtagListCreator( snapshot.data ),
                          );
                        }
                      ),
                    ),
                  ),
                ]
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _pinnedSliverItem( postNumber: widget.userData['userPostList'].length ),
            ),
            FutureBuilder(
              future: DataBase().getDBPostDataListFromPostIDList( widget.userData['userPostList'] ),
              builder: (context, snapshot) {
                return PostListViewWidget(
                  postDataList: snapshot.data,
                  onTapToSubPage:(int pageIndex) => widget.onTapToSubPage(pageIndex),
                );
              }
            ),
          ],
        ),
      ),
    );
  }
}


class _pinnedSliverItem extends SliverPersistentHeaderDelegate {
  final postNumber;
  _pinnedSliverItem({
    this.postNumber,
  });

  double _size = 40;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          RichText(
            text: TextSpan(
              text: postNumber.toString(),
              style: TextStyle(
                color: Defines.colorset['darkdrawcolor'],
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
          ),
          RichText(
            text: TextSpan(
              text: ' 件の投稿',
              style: TextStyle(
                color: Defines.colorset['drawcolor'],
                fontWeight: FontWeight.normal,
                fontSize: 14.0,
              ),
            ),
          ),
        ],
      ),
      decoration: BoxDecoration(
        color: Defines.colorset['backgroundcolor'],
        border: Border(
          bottom: BorderSide(
            width: 1.0,
            color: Defines.colorset['drawcolor']
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => _size;

  @override
  double get minExtent => _size;

  @override
  bool shouldRebuild(_pinnedSliverItem oldDelegate) {
    return oldDelegate._size != _size;
  }
}


class _editButton extends StatelessWidget {
  final Function onPressEditButton;
  _editButton({
    this.onPressEditButton
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomRight,
      child: Center(
        child: RaisedButton(
          color: Defines.colorset['backgroundcolor'],
          child: Text(
            '編集',
            style: TextStyle(
              color: Defines.colorset['drawcolor'],
              fontWeight: FontWeight.normal,
            ),
          ),
          shape: StadiumBorder(
            side: BorderSide(
              color: Defines.colorset['drawcolor'],
            ),
          ),
          onPressed: onPressEditButton,
        ),
      ),
    );
  }
}

class _keepReleaseButton extends StatelessWidget {
  final bool isKeep;
  final Function onPressKeepReleaseButton;
  _keepReleaseButton({
    this.isKeep,
    this.onPressKeepReleaseButton
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      child: RaisedButton(
        color: isKeep
            ? Defines.colorset['keepusercolor']
            : Defines.colorset['backgroundcolor'],
        child: Text(
          isKeep ? '保存済み' : 'リストに追加',
          style: TextStyle(
            color: isKeep
                ? Colors.white
                : Defines.colorset['drawcolor'],
            fontWeight: isKeep
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
        shape: StadiumBorder(
          side: BorderSide(
            color: isKeep
                ? Defines.colorset['keepusercolor']
                : Defines.colorset['drawcolor'],
          ),
        ),
        onPressed: onPressKeepReleaseButton,
      ),
    );
  }
}

