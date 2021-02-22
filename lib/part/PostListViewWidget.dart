
import 'package:flutter/material.dart';
import 'package:test_roketan/page/PostDetail.dart';
import 'package:test_roketan/part/DataBase.dart';
import 'package:test_roketan/part/DataManager.dart';

import 'package:test_roketan/part/Defines.dart' as Defines;
import 'package:test_roketan/part/Hashtag.dart';
import 'package:test_roketan/view/MainView.dart';


class PostListViewWidget extends StatefulWidget {
  final List<Map<String, dynamic>> postDataList;
  final Function onTappedTopTab;
  final Function onTapToSubPage;

  PostListViewWidget({
    this.postDataList,
    this.onTappedTopTab,
    this.onTapToSubPage,
  });

  @override
  _PostListViewWidgetState createState() => _PostListViewWidgetState();
}

class _PostListViewWidgetState extends State<PostListViewWidget> {

  //データマネージャのインスタンス生成
  ViewDataManager _vdm = new ViewDataManager();
  ActiveAccountDataManager _aadm = new ActiveAccountDataManager();

  _onTapFavorite( int index ){
    var _myAccountID;
    var _favoriteUserList = [];
    var _postID;

    _myAccountID = _aadm.getAccountData('id');
    _favoriteUserList = widget.postDataList[index]['favoriteUserList'];
    _postID = widget.postDataList[index]['id'];

    //ログ保存用
    DataBase().addOperationLog( 'favorite $_postID' );

    if( _isFavorite(index) == false ){
      setState(() {
        _favoriteUserList.add(_myAccountID);
        DataBase().updatePostInfo( widget.postDataList[index]['id'], 'favoriteUserList', _myAccountID, 'add');
      });
    }
    else{
      setState(() {
        _favoriteUserList.removeAt( _favoriteUserList.indexOf(_myAccountID) );
        DataBase().updatePostInfo( widget.postDataList[index]['id'], 'favoriteUserList', _myAccountID, 'remove');
      });
    }

  }

  bool _isFavorite( int index ){
    var _myAccountID;
    var _favoriteUserList = [];
    var _postID;

    _myAccountID = _aadm.getAccountData('id');
    _favoriteUserList = widget.postDataList[index]['favoriteUserList'];


    if( _favoriteUserList.indexOf(_myAccountID) == -1 ){
      return false;
    } else {
      return true;
    }
  }

  _onTapPostToPostDetailPage( int postIndex ) async{
    var _postInfo = widget.postDataList[ postIndex ];
    _vdm.setViewData('selectedPostInfo', _postInfo);
    var _spotID = _postInfo['postSpot'];
    var _spotInfo = await DataBase().getDBSpotDataOnlyFromSpotID(_spotID);
    _vdm.setViewData('selectedSpotInfo', _spotInfo);

    //ログ保存用
    DataBase().addOperationLog( 'to post detail page ${_postInfo['id']}' );

    //ページ遷移
    widget.onTapToSubPage(SubPageName.PostDetail.index);
  }

  _onTapUserToProfilePage( int postIndex ) async{
    var _userID;
    var _userInfo;

    _userID = widget.postDataList[ postIndex ]['postUserInfo'];
    _userInfo = await DataBase().getDBUserDataOnlyFromUserID( _userID );

    _vdm.setViewData('selectedUserInfo', _userInfo);

    //ログ保存用
    DataBase().addOperationLog( 'to profile page $_userID' );

    //ページ遷移
    widget.onTapToSubPage(SubPageName.Profile.index);

  }


  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (BuildContext context, int postIndex){
          return Column(
            children: [
              Container(
                child: FutureBuilder<Map<String, dynamic>>(
                  future: DataBase().getDBUserDataOnlyFromUserID( widget.postDataList[postIndex]['postUserInfo'] ),
                  builder: (context, snapshot) {
                    return !snapshot.hasData ? Container() : Row(
                      children: [
                        SizedBox( width: 10 ),
                        GestureDetector(
                          onTap: () {
                            _onTapUserToProfilePage( postIndex );
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage: snapshot.data['profileIcon'] == ''
                                ? Image.asset( 'assets/noimage.png' ).image
                                : Image.network( snapshot.data['profileIcon'] ).image,
                          ),
                        ),
                        SizedBox( width: 10 ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              _onTapUserToProfilePage( postIndex );
                            },
                            child: Container(
                              height: 50.0,
                              alignment: Alignment.centerLeft,
                              child: RichText(
                                text: TextSpan(
                                  text: snapshot.data['nickname'],
                                  style: TextStyle(
                                    color: Defines.colorset['darkdrawcolor'],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.0,
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
                          height: 50.0,
                          child: Center(
                            child: RichText(
                              text: TextSpan(
                                text: widget.postDataList[postIndex]['postDate'],
                                style: TextStyle(
                                  color: Defines.colorset['drawcolor'],
                                  fontWeight: FontWeight.normal,
                                  fontSize: 10.0,
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
                margin: EdgeInsets.only( bottom: 5, left: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        child: GestureDetector(
                          onTap: (){
                            _onTapPostToPostDetailPage( postIndex );
                          },
                          child: RichText(
                            text: TextSpan(
                              text: widget.postDataList[postIndex]['postTitle'],
                              style: TextStyle(
                                color: Defines.colorset['darkdrawcolor'],
                                fontWeight: FontWeight.normal,
                                fontSize: 14.0,
                                fontStyle: FontStyle.italic,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
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
                                _isFavorite( postIndex ) ? Icons.favorite : Icons.favorite_border,
                                color: _isFavorite( postIndex ) ? Defines.colorset['highlightcolor'] : Defines.colorset['drawcolor'],
                              ),
                              onPressed: (){
                                _onTapFavorite(postIndex);
                              },
                            ),
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            width: 60,
                            child: Text(
                              widget.postDataList[postIndex]['favoriteUserList'].length.toString(),
                              style: TextStyle(
                                color: _isFavorite( postIndex) ? Defines.colorset['highlightcolor'] : Defines.colorset['drawcolor'],
                                fontWeight: _isFavorite( postIndex ) ? FontWeight.bold : FontWeight.normal,
                                fontSize: _isFavorite( postIndex ) ? 16 : 12,
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
                margin: EdgeInsets.only(bottom: 5,left: 36, right: 20),
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: (){
                    _onTapPostToPostDetailPage( postIndex );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: widget.postDataList[postIndex]['text'],
                      style: TextStyle(
                        height: 1.0,
                        color: Defines.colorset['darkdrawcolor'],
                        fontWeight: FontWeight.normal,
                        fontSize: 14.0,
                      ),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 10,
                  ),
                ),
              ),
              Container(
                //画像
                margin: EdgeInsets.only(bottom: 5, left: 20, right: 20),
                height: widget.postDataList[postIndex]['postImageList'].length != 0 ? 100 : 0,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.postDataList[postIndex]['postImageList'].length ,
                  itemBuilder: (BuildContext context, int imageIndex){
                    return Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.all(5),
                      width: 100,
                      height: 100,
                      child: Image.network( widget.postDataList[postIndex]['postImageList'][imageIndex] ),
                    );
                  },
                ),
              ),
              FutureBuilder(
                future: DataBase().getDBHashtagDataListFromHashtagIDList( widget.postDataList[postIndex]['postHashtagList'] ),
                builder: (context, snapshot) {
                  return !snapshot.hasData ? Container() :Container(
                    //ハッシュタグ
                    margin: EdgeInsets.only(left: 10, right: 10),
                    height: 24,
                    width: double.infinity,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.postDataList[postIndex]['postHashtagList'].length,
                      itemBuilder: (BuildContext context, int hashtagIndex) {
                        Map<String, dynamic> _hashtagNameMapData = snapshot.data[hashtagIndex];
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
          );
        },
        childCount: widget.postDataList != null ? widget.postDataList.length : 0,
      ),
    );
  }
}