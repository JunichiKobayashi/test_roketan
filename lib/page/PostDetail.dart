
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:selectable_autolink_text/selectable_autolink_text.dart';
import 'package:test_roketan/page/SearchResult.dart';
import 'package:test_roketan/part/DataBase.dart';
import 'package:test_roketan/part/DataManager.dart';

import 'package:test_roketan/part/Defines.dart' as Defines;
import 'package:test_roketan/part/Hashtag.dart';
import 'package:test_roketan/part/MapPinInfo.dart';
import 'package:test_roketan/part/NarrowDown.dart';
import 'package:test_roketan/view/MainView.dart';
import 'package:url_launcher/url_launcher.dart';



class PostDetail extends StatefulWidget {
  final postData;
  final Function onTapUserToProfilePage;
  final Function onTappedTopTab;
  final Function onTapToSubPage;
  final StreamController<Map<String, dynamic>> pinsSpotStreamController;

  PostDetail({
    this.postData,
    this.onTapUserToProfilePage,
    this.onTappedTopTab,
    this.onTapToSubPage,
    this.pinsSpotStreamController,
  });

  @override
  _PostDetailState createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {

  final _postDataDetailStreamController = StreamController<Map<String, dynamic>>();
  final _pinsSpotStreamController = StreamController<Map<String, dynamic>>();

  Map<String, dynamic> _postDataDetailObj = {
    'pinSpotOffstage': false,
  };

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _postDataDetailStreamController.stream,
      initialData: _postDataDetailObj,
      builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        return Stack(
          children: [
            GestureDetector(
              onTap: () {
                print('here');
                _postDataDetailObj['pinSpotOffstage'] = false;
                _postDataDetailStreamController.sink.add(_postDataDetailObj);
              },
              child: PostDetailContents(
                postData: widget.postData,
                onTapUserToProfilePage: widget.onTapUserToProfilePage,
                pinsSpotStreamController: _pinsSpotStreamController,
                postDataDetailStreamController: _postDataDetailStreamController,
                onTapToSubPage: widget.onTapToSubPage,
              ),
            ),
          ],
        );
      },
    );
  }
}

class PostDetailContents extends StatefulWidget {
  @override

  final postData;
  final Function onTapUserToProfilePage;
  final StreamController pinsSpotStreamController;
  final StreamController postDataDetailStreamController;
  final Function onTappedTopTab;
  final Function onTapToSubPage;

  PostDetailContents({
    this.postData,
    this.onTapUserToProfilePage,
    this.pinsSpotStreamController,
    this.postDataDetailStreamController,
    this.onTappedTopTab,
    this.onTapToSubPage,
  });

  _PostDetailContents createState() => _PostDetailContents();
}

class _PostDetailContents extends State<PostDetailContents> {

  //データマネージャのインスタンス生成
  ViewDataManager _vdm = new ViewDataManager();
  ActiveAccountDataManager _aadm = new ActiveAccountDataManager();

  bool _offstageCaution = true;

  bool _isFavorite(){
    var _myAccountID;
    var _favoriteUserList = [];

    _myAccountID = _aadm.getAccountData('id');
    _favoriteUserList = widget.postData['favoriteUserList'];

    if( _favoriteUserList.indexOf(_myAccountID) == -1 ){
      return false;
    }
    else{
      return true;
    }
  }

  _onTapFavorite(){
    var _myAccountID;
    var _favoriteUserList = [];

    _myAccountID = _aadm.getAccountData('id');
    _favoriteUserList = widget.postData['favoriteUserList'];

    //操作ログ用
    DataBase().addOperationLog( 'favorite ${widget.postData['id']}' );

    if( _isFavorite() == false ){
      setState(() {
        _favoriteUserList.add(_myAccountID);
        DataBase().updatePostInfo( widget.postData['id'], 'favoriteUserList', _myAccountID, 'add');
      });
    }
    else{
      setState(() {
        _favoriteUserList.removeAt(_favoriteUserList.indexOf(_myAccountID));
        DataBase().updatePostInfo( widget.postData['id'], 'favoriteUserList', _myAccountID, 'remove');
      });
    }
  }

  _onTapUserToProfilePage() async{
    var _userID;
    var _userInfo;

    _userID = widget.postData['postUserInfo'];
    _userInfo = await DataBase().getDBUserDataOnlyFromUserID( _userID );

    //操作ログ用
    DataBase().addOperationLog( 'to profile page $_userID' );

    _vdm.setViewData('selectedUserInfo', _userInfo);
    widget.onTapUserToProfilePage(SubPageName.Profile.index);
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: DataBase().getDBSpotDataOnlyFromSpotID( widget.postData['postSpot'] ),
      builder: (context, snapshotSpotInfo) {
        return !snapshotSpotInfo.hasData ? Container() : Container(
          width: double.infinity,
          height: double.infinity,
          color: Defines.colorset['backgroundcolor'],
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Defines.colorset['drawcolor'],
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60,
                            child: Icon(
                              Icons.flag,
                              color: Defines.colorset['drawcolor'],
                              size: 40.0,
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async{

                                Map<String, dynamic> _selectSpotInfo = _vdm.getViewData('selectedSpotInfo');
                                Map<String, dynamic> _sinkPinSpotObj;

                                var postData = await postDataFromSpotNameNarrowList(_selectSpotInfo['LocName']);

                                //操作ログ用
                                DataBase().addOperationLog( 'push spot ${_selectSpotInfo['id']}' );

                                _sinkPinSpotObj = {
                                  'selectedSpotInfo':  _selectSpotInfo,
                                  'selectedSpotName':  _selectSpotInfo['LocName'],
                                  'selectedLatitude':  _selectSpotInfo['Latitude'],
                                  'selectedLongitude': _selectSpotInfo['Longitude'],
                                  '_isSpotSelected': true,
                                  'postData': postData,
                                };
                                _vdm.setViewData('_sinkPinSpotObj', _sinkPinSpotObj);
                                _vdm.setViewData('selectedBN', 0);

                                Navigator.of(context).pushReplacement(MaterialPageRoute( builder: (context) => MainView(), ));
                              },
                              child: Container(
                                child: RichText(
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(
                                    text: snapshotSpotInfo.data['LocName'],
                                    style: TextStyle(
                                      color: Defines
                                          .colorset['darkdrawcolor'],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 50,
                            child: IconButton(
                              icon: Icon(
                                Icons.share,
                                color: Defines.colorset['drawcolor'],
                              ),
                              iconSize: 40,
                              onPressed: (){},
                            ),
                          ),
                          Container(
                            width: 50,
                            child: IconButton(
                              icon: Icon(
                                Icons.directions_car,
                                color: Defines.colorset['highlightcolor'],
                              ),
                              iconSize: 40.0,
                              onPressed: (){

                                //操作ログ用
                                DataBase().addOperationLog( 'push route guide' );

                                if( _aadm.getAccountData('isPremium') ){
                                  String lat = _vdm.getViewData('selectedSpotInfo')['Latitude'];
                                  String lng = _vdm.getViewData('selectedSpotInfo')['Longitude'];
                                  String url = "https://www.google.com/maps/dir/?api=1&destination=${lat},${lng}";
                                  launch(url);
                                } else {
                                  setState(() {
                                    _offstageCaution = false;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      Offstage(
                        offstage: _offstageCaution,
                        child: Container(
                          width: double.infinity,
                          height: 60,
                          color: Colors.grey[300].withOpacity(0.9),
                          child: Row(
                            children: [
                              Expanded(
                                child: Center(
                                  child: Text(
                                    'プレミアム会員登録するとルート案内がご利用になれます',
                                    style: TextStyle(
                                      color: Defines.colorset['darkdrawcolor'],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                child: FlatButton(
                                  child: Text('OK'),
                                  onPressed: (){
                                    setState(() {
                                      _offstageCaution = true;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    children: [
                      Container(
                        child: FutureBuilder<Map<String, dynamic>>(
                          future: DataBase().getDBUserDataOnlyFromUserID( widget.postData['postUserInfo'] ),
                          builder: (context, snapshotUserInfo) {
                            return !snapshotUserInfo.hasData ? Container() : Row(
                              children: [
                                SizedBox( width: 10 ),
                                GestureDetector(
                                  onTap: () {
                                    _onTapUserToProfilePage();
                                  },
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    backgroundImage: Image.network( snapshotUserInfo.data['profileIcon'] ).image,
                                  ),
                                ),
                                SizedBox( width: 10 ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      _onTapUserToProfilePage();
                                    },
                                    child: Container(
                                      height: 60.0,
                                      alignment: Alignment.centerLeft,
                                      child: RichText(
                                        text: TextSpan(
                                          text: snapshotUserInfo.data['nickname'],
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
                                Container(
                                  alignment: Alignment.centerRight,
                                  width: 120.0,
                                  height: 60.0,
                                  child: Center(
                                    child: RichText(
                                      text: TextSpan(
                                        text: widget.postData['postDate'],
                                        style: TextStyle(
                                          color: Defines.colorset['drawcolor'],
                                          fontWeight: FontWeight.normal,
                                          fontSize: 12.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only( bottom: 10, left: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: GestureDetector(
                                  onTap: (){},

                                  child: SelectableLinkify(
                                    onOpen: (link) async {
                                      if (await canLaunch(link.url)) {
                                        await launch(link.url);
                                      } else {
                                        throw 'Could not launch $link';
                                      }
                                    },
                                    text: widget.postData['postTitle'],
                                    style: TextStyle(
                                      color: Defines.colorset['darkdrawcolor'],
                                      fontWeight: FontWeight.normal,
                                      fontSize: 20.0,
                                      fontStyle: FontStyle.italic,
                                      decoration: TextDecoration.underline,
                                    ),
                                    linkStyle: TextStyle(color: Colors.blueAccent),
                                  ),

                                  /*
                                  child: RichText(
                                    text: TextSpan(
                                      text: widget.postData['postTitle'],
                                      style: TextStyle(
                                        color: Defines.colorset['darkdrawcolor'],
                                        fontWeight: FontWeight.normal,
                                        fontSize: 24.0,
                                        fontStyle: FontStyle.italic,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                   */

                                ),
                              ),
                            ),
                            Container(
                              width: 120,
                              child: Row(
                                children: [
                                  Container(
                                    alignment: Alignment.centerRight,
                                    width: 60,
                                    child: IconButton(
                                      icon: Icon(
                                        _isFavorite() ? Icons.favorite : Icons.favorite_border,
                                        color: _isFavorite() ? Defines.colorset['highlightcolor'] : Defines.colorset['drawcolor'],
                                      ),
                                      onPressed: (){
                                        _onTapFavorite();
                                      },
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    width: 60,
                                    child: Text(
                                      widget.postData['favoriteUserList'].length.toString(),
                                      style: TextStyle(
                                        color: _isFavorite() ? Defines.colorset['highlightcolor'] : Defines.colorset['drawcolor'],
                                        fontWeight: _isFavorite() ? FontWeight.bold : FontWeight.normal,
                                        fontSize: _isFavorite() ? 20 : 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        //本文
                        margin: EdgeInsets.only(bottom: 10,left: 36, right: 20),
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: (){},
                          /*
                          child: SelectableText(
                            widget.postData['text'],
                            style: TextStyle(
                              height: 1.0,
                              color: Defines.colorset['darkdrawcolor'],
                              fontWeight: FontWeight.normal,
                              fontSize: 20.0,
                            ),
                          ),
                           */

                          child: SelectableLinkify(
                            onOpen: (link) async {
                              if (await canLaunch(link.url)) {
                                await launch(link.url);
                              } else {
                                throw 'Could not launch $link';
                              }
                            },
                            text: widget.postData['text'],
                            style: TextStyle(
                              height: 1.0,
                              color: Defines.colorset['darkdrawcolor'],
                              fontWeight: FontWeight.normal,
                              fontSize: 16.0,
                            ),
                            linkStyle: TextStyle(color: Colors.blueAccent),
                          ),


                        ),
                      ),
                      Container(
                        //画像
                        margin: EdgeInsets.only(bottom: 10, left: 20, right: 20),
                        height: widget.postData['postImageList'].length != 0 ? 200 : 0,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.postData['postImageList'].length ,
                          itemBuilder: (BuildContext context, int imageIndex){
                            return Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.all(5),
                              width: 200,
                              height: 200,
                              child: Image.network( widget.postData['postImageList'][imageIndex] ),
                            );
                          },
                        ),
                      ),
                      FutureBuilder(
                        future: DataBase().getDBHashtagDataListFromHashtagIDList( widget.postData['postHashtagList'] ),
                        builder: (context, snapshotHashtagInfo) {
                          return !snapshotHashtagInfo.hasData ? Container() : Container(
                            //ハッシュタグ
                            padding: EdgeInsets.only(left: 10, right: 10),
                            height: 24,
                            width: double.infinity,
                            //color: Colors.deepPurpleAccent,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: widget.postData['postHashtagList'].length,
                              itemBuilder: (BuildContext context, int hashtagIndex) {
                                Map<String, dynamic> _hashtagNameMapData = snapshotHashtagInfo.data[hashtagIndex];
                                String _hashtagName = _hashtagNameMapData['hashtag'];
                                return Container(
                                  margin: EdgeInsets.only(right: 4),
                                  child: hashtagCreator(_hashtagName),
                                );
                              },
                            ),
                          );
                        }
                      ),
                      Container(
                        height: 16.0,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Defines.colorset['drawcolor']),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

}