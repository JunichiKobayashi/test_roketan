
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:test_roketan/page/SearchResult.dart';
import 'package:test_roketan/part/DataManager.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase/firebase.dart' as fb;
import 'dart:math';


class DataBase{

  ActiveAccountDataManager _aadm = new ActiveAccountDataManager();


  Future<void> addOperationLog( String operation ) async{

    bool existFlag = false;
    String documentID = _aadm.getAccountData('id');
    DateTime now = new DateTime.now();
    var timeStamp = now.toString();

    QuerySnapshot querySnapshot = await Firestore.instance.collection("operation_log").getDocuments();
    var operationLogList = await querySnapshot.documents;
    for( int i=0; i<operationLogList.length; i++ ){
      //既にこのユーザーのログデータが存在しているなら、何もしない
      if( documentID == operationLogList[i].documentID ){
        existFlag = true;
      }
    }
    if( existFlag == false ){
      //このユーザーのログデータが存在しない場合、ログデータ蓄積用配列を作成する
      await Firestore.instance
          .collection('operation_log') // コレクションID
          .document(documentID) // ドキュメントID
          .setData(
          {
            "log_data": [],
          }
      ); // データ
    }
    await Firestore.instance.collection( 'operation_log' ).document( documentID )
        .update( {
      'log_data': FieldValue.arrayUnion( [ '$timeStamp $operation' ] )
    } );
  }



  Future<void> author( String email, String password ) async{

    //QuerySnapshot postlist = await Firestore.instance.collection("post_info").getDocuments();
    //QuerySnapshot spotlist = await Firestore.instance.collection("spot_info").getDocuments();
    //print('post:${postlist.documents.length}, spot:${spotlist.documents.length}');

    //IDとパスワードが一致したらデータマネージャにアカウント情報をセットする。
    //print( '1' );
    QuerySnapshot querySnapshot = await Firestore.instance.collection("user_info").getDocuments();
    //print( '2' );
    var list = await querySnapshot.documents;
    for( int i=0; i<list.length; i++ ){
      if( email == await list[i]['email'] ){
        if( password == await list[i]['password'] ){
          //print( '3' );
          _aadm.setAccountData( 'id', list[i].documentID );
          //print( '4' );
          _aadm.setAccountData( 'email', list[i]['email'] );
          //print( '5' );
          _aadm.setAccountData( 'nickname', list[i]['nickname']);
          //print( '6' );
          //twitterInfo
          //instagramInfo
          _aadm.setAccountData( 'isPremium', list[i]['is_premium'] );
          //print( '7' );
          _aadm.setAccountData( 'profileIcon', list[i]['profile_icon'] );
          //print( '8' );
          _aadm.setAccountData( 'introduction', list[i]['introduction'] );
          //print( '9' );
          _aadm.setAccountData( 'profileHashtagList', list[i]['profile_hashtag_list'] );
          //print( '10' );
          _aadm.setAccountData( 'userPostList', list[i]['user_posts_list'] );

          //narrowDownHashtagListは仮置き
          List<List<String>> _tmp = [['']];
          if( list[i]['narrow_down_hashtag_list2'].length == 0 ){
            if( list[i]['narrow_down_hashtag_list1'].length == 0 ){
              if( list[i]['narrow_down_hashtag_list0'].length == 0 ){
                _aadm.setAccountData( 'narrowDownHashtagList', [ [''] ] );
              } else {
                _tmp = [ list[i]['narrow_down_hashtag_list0'].cast<String>() ];
                _aadm.setAccountData( 'narrowDownHashtagList', _tmp );
              }
            } else {
              _tmp = [
                list[i]['narrow_down_hashtag_list0'].cast<String>(),
                list[i]['narrow_down_hashtag_list1'].cast<String>(),
              ];
              _aadm.setAccountData( 'narrowDownHashtagList', _tmp );
            }
          } else {
            _tmp = [
              list[i]['narrow_down_hashtag_list0'].cast<String>(),
              list[i]['narrow_down_hashtag_list1'].cast<String>(),
              list[i]['narrow_down_hashtag_list2'].cast<String>(),
            ];
            _aadm.setAccountData( 'narrowDownHashtagList', _tmp );
          }
          //print( '11' );

          _aadm.setAccountData( 'keepUserInfoList', list[i]['keep_user_info_list'] );
          //print( '12' );
          _aadm.setAccountData( 'keepSpotInfoList', list[i]['keep_spot_info_list'] );
          //print( '13' );
          _aadm.setAccountData( 'haveBeenSpotInfoList', list[i]['have_been_spot_info_list'] );
          //print( '14' );
          return;
        }
      }
    }
    return;
  }


  Future<String> uploadAndGetUrl( String userId, String fileName, dynamic imageData ) async{
    String ref = 'gs://test-roketan.appspot.com/';
    fb.StorageReference storageReference = fb.storage().refFromURL(ref).child('profileIcon/$userId/$fileName');
    fb.UploadTaskSnapshot uploadTaskSnapshot = await storageReference.put(imageData).future;
    Uri imageUri = await uploadTaskSnapshot.ref.getDownloadURL();
    return imageUri.toString();
  }

  Future<String> uploadPostImageAndGetUrl( String postId, String fileName, dynamic imageData ) async{
    String ref = 'gs://test-roketan.appspot.com/';
    fb.StorageReference storageReference = fb.storage().refFromURL(ref).child('postImage/$postId/$fileName');
    fb.UploadTaskSnapshot uploadTaskSnapshot = await storageReference.put(imageData).future;
    Uri imageUri = await uploadTaskSnapshot.ref.getDownloadURL();
    return imageUri.toString();
  }


  Future<void> setUserInfo( String userID, String key, dynamic data ) async{
    switch( key ){
      case 'nickname':
        await Firestore.instance.collection( 'user_info' ).document( userID ).updateData( { 'nickname': data } );
        break;
      case 'introduction':
        await Firestore.instance.collection( 'user_info' ).document( userID ).updateData( { 'introduction': data } );
        break;
      case 'profileIcon':
        await Firestore.instance.collection( 'user_info' ).document( userID ).updateData( { 'profile_icon': data } );
        break;
      case 'profileHashtagList':
        await Firestore.instance.collection( 'user_info' ).document( userID ).updateData( { 'profile_hashtag_list': data } );
        break;
      case 'narrowDownHashtagList':
        int i;
        for( i=0; i<data.length; i++ ){
          await Firestore.instance.collection( 'user_info' ).document( userID ).updateData( { 'narrow_down_hashtag_list$i': data[i] } );
        }
        for( i=data.length; i<3; i++ ){
          await Firestore.instance.collection( 'user_info' ).document( userID ).updateData( { 'narrow_down_hashtag_list$i': [] } );
        }
        break;
      case 'userPostList':
        await Firestore.instance.collection( 'user_info' ).document( userID ).updateData( { 'user_posts_list': data } );
        break;
      case 'keepUserInfoList':
        await Firestore.instance.collection( 'user_info' ).document( userID ).updateData( { 'keep_user_info_list': data } );
        break;
      case 'keepSpotInfoList':
        await Firestore.instance.collection( 'user_info' ).document( userID ).updateData( { 'keep_spot_info_list': data } );
        break;
      case 'haveBeenSpotInfoList':
        await Firestore.instance.collection( 'user_info' ).document( userID ).updateData( { 'have_been_spot_info_list': data } );
        break;
    }
  }


  //新規投稿の登録処理用の関数
  //画像のURLは投稿IDを取得した後にUPLOADを使って編集する
  Future<void> setPostInfo( String postTitle, String text, List<String> hashtagIDList, String spotID ) async{

    var userID = _aadm.getAccountData('id');
    DateTime now = new DateTime.now();
    var postDate = '${now.year}/${now.month}/${now.day}';

    await Firestore.instance
        .collection('post_info') // コレクションID
        .document() // ドキュメントID
        .setData(
        {
          'post_title': postTitle,
          'text': text,
          'post_user_info': userID,
          'post_date': postDate,
          'post_image_list': [],
          'post_hashtag_list': hashtagIDList,
          'favorite_user_list': [],
          'spot_id': spotID,
        }
    ); // データ
  }


  //投稿情報の更新用の関数
  //favoriteUserListの更新は、自分のユーザーIDを引数として渡し、かつオプション引数で、addまたはremoveを指定する
  Future<void> updatePostInfo( String postID, String key, dynamic data, [String option] ) async{
    switch( key ){
      case 'postTitle':
        await Firestore.instance.collection( 'post_info' ).document( postID ).updateData( { 'post_title': data } );
        break;
      case 'text':
        await Firestore.instance.collection( 'post_info' ).document( postID ).updateData( { 'text': data } );
        break;
      case 'postImageList':
        await Firestore.instance.collection( 'post_info' ).document( postID ).updateData( { 'post_image_list': data } );
        break;
      case 'postHashtagList':
        await Firestore.instance.collection( 'post_info' ).document( postID ).updateData( { 'post_hashtag_list': data } );
        break;
      case 'favoriteUserList':
        if( option == 'add' ){
          await Firestore.instance.collection( 'post_info' ).document( postID )
              .update( {
                'favorite_user_list': FieldValue.arrayUnion( [ data ] )
              } );
        }
        if( option == 'remove' ){
          await Firestore.instance.collection( 'post_info' ).document( postID )
              .update( {
            'favorite_user_list': FieldValue.arrayRemove( [ data ] )
          } );
        }
        break;
    }
  }


  //新規聖地の登録処理用の関数
  Future<void> setSpotInfo( String spotName, String latitude, String longitude ) async{
    await Firestore.instance
        .collection('spot_info') // コレクションID
        .document() // ドキュメントID
        .setData(
        {
          'spot_name': spotName,
          'latitude': latitude,
          'longitude': longitude,
          'post_to_spot_list': [],
          'keep_stop_user_info_list': [],
          'have_been_spot_user_info_list': [],
        }
    ); // データ
  }



  //聖地情報の更新用の関数
  //各種Listの更新は、必要なID情報を引数として渡し、かつオプション引数で、addまたはremoveを指定する
  Future<void> updateSpotInfo( String spotID, String key, dynamic data, [String option] ) async{
    switch( key ){
      case 'PostToLoc':
        if( option == 'add' ){
          await Firestore.instance.collection( 'spot_info' ).document( spotID )
              .update( {
            'post_to_spot_list': FieldValue.arrayUnion( [ data ] )
          } );
        }
        if( option == 'remove' ){
          await Firestore.instance.collection( 'spot_info' ).document( spotID )
              .update( {
            'post_to_spot_list': FieldValue.arrayRemove( [ data ] )
          } );
        }
        break;
      case 'keepSpotUserInfoList':
        if( option == 'add' ){
          await Firestore.instance.collection( 'spot_info' ).document( spotID )
              .update( {
            'keep_stop_user_info_list': FieldValue.arrayUnion( [ data ] )
          } );
        }
        if( option == 'remove' ){
          await Firestore.instance.collection( 'spot_info' ).document( spotID )
              .update( {
            'keep_stop_user_info_list': FieldValue.arrayRemove( [ data ] )
          } );
        }
        break;
      case 'haveBeenUserInfoList':
        if( option == 'add' ){
          await Firestore.instance.collection( 'spot_info' ).document( spotID )
              .update( {
            'have_been_spot_user_info_list': FieldValue.arrayUnion( [ data ] )
          } );
        }
        if( option == 'remove' ){
          await Firestore.instance.collection( 'spot_info' ).document( spotID )
              .update( {
            'have_been_spot_user_info_list': FieldValue.arrayRemove( [ data ] )
          } );
        }
        break;
    }
  }




  //条件に合うユーザー情報のリストを返す関数
  //自分のユーザー情報は除外して返す
  Future<List<Map<String, dynamic>>> getDBUserData( [dynamic data] ) async{
    List<Map<String, dynamic>> list =[];

    QuerySnapshot querySnapshot = await Firestore.instance.collection("user_info").getDocuments();
    var userList = await querySnapshot.documents;

    for( int i=0; i<userList.length; i++ ){
      Map<String, dynamic> tmpMap =
      {
        'id': userList[i].documentID,
        'profileIcon': userList[i]['profile_icon'],
        'nickname': userList[i]['nickname'],
        'introduction': userList[i]['introduction'],
        'profileHashtagList': userList[i]['profile_hashtag_list'],
        'userPostList': userList[i]['user_posts_list'],
      };
      //自分の情報は除外
      if( userList[i].documentID != _aadm.getAccountData('id') ){
        list.add(tmpMap);
      }
    }
    //リストの順番をランダムにシャッフル
    list = _shuffle(list);
    return list;
  }

  //リストの順番をランダムにシャッフル
  List _shuffle(List items) {
    var random = new Random();
    for (var i = items.length - 1; i > 0; i--) {
      var n = random.nextInt(i + 1);
      var temp = items[i];
      items[i] = items[n];
      items[n] = temp;
    }
    return items;
  }


  //条件に合う投稿情報のリストを返す関数
  Future<List<Map<String, dynamic>>> getDBPostData( [dynamic data] ) async{
    List<Map<String, dynamic>> list = [];

    QuerySnapshot querySnapshot = await Firestore.instance.collection("post_info").getDocuments();
    var postList = await querySnapshot.documents;

    for( int i=0; i<postList.length; i++ ){
      Map<String, dynamic> tmpMap =
      {
        'id': postList[i].documentID,
        'postTitle': postList[i]['post_title'],
        'text': postList[i]['text'],
        'postUserInfo': postList[i]['post_user_info'],
        'postDate': postList[i]['post_date'],
        'postImageList': postList[i]['post_image_list'],
        'postHashtagList': postList[i]['post_hashtag_list'],
        'favoriteUserList': postList[i]['favorite_user_list'],
        'postSpot': postList[i]['spot_id'],
      };
      list.add(tmpMap);
    }
    return list;
  }

  //条件に合う聖地情報のリストを返す関数
  Future<List<Map<String, dynamic>>> getDBSpotData( [dynamic data] ) async{
    List<Map<String, dynamic>> list = [];

    QuerySnapshot querySnapshot = await Firestore.instance.collection("spot_info").getDocuments();
    var spotList = await querySnapshot.documents;

    for( int i=0; i<spotList.length; i++ ){
      Map<String, dynamic> tmpMap =
      {
        'id': spotList[i].documentID,
        'LocName': spotList[i]['spot_name'],
        'Latitude': spotList[i]['latitude'],
        'Longitude': spotList[i]['longitude'],
        'PostToLoc': spotList[i]['post_to_spot_list'],
        'keepSpotUserInfoList': spotList[i]['keep_stop_user_info_list'],
        'haveBeenUserInfoList': spotList[i]['have_been_spot_user_info_list'],
      };
      list.add(tmpMap);
    }
    return list;
  }

  //条件に合うハッシュタグ情報のリストを返す関数
  Future<List<Map<String, dynamic>>> getDBHashtagData( [dynamic data] ) async{
    List<Map<String, dynamic>> list = [];

    QuerySnapshot querySnapshot = await Firestore.instance.collection("hashtag_info").getDocuments();
    var hashtagList = await querySnapshot.documents;

    for( int i=0; i<hashtagList.length; i++ ){
      Map<String, dynamic> tmpMap =
      {
        'id': hashtagList[i].documentID,
        'hashtag': hashtagList[i]['hashtag'],
      };
      list.add(tmpMap);
    }
    return list;
  }


  Future<Map<String, dynamic>> getDBUserDataOnlyFromUserID( String userID ) async{
    var document = await Firestore.instance.collection('user_info').document(userID).get();
    Map<String, dynamic> userInfo =
    {
      'id': userID,
      'profileIcon': document['profile_icon'],
      'nickname': document['nickname'],
      'introduction': document['introduction'],
      'profileHashtagList': document['profile_hashtag_list'],
      'userPostList': document['user_posts_list'],
    };
    return userInfo;
  }


  //ユーザーIDのリストからユーザー情報のリストへ変換する関数
  //自分のIDは除外して返す
  Future<List<Map<String, dynamic>>> getDBUserDataListFromUserIDList( List<dynamic> userIDList ) async{
    List<Map<String, dynamic>> list =[];

    for( int i=0; i<userIDList.length; i++ ){
      var document = await Firestore.instance.collection('user_info').document(userIDList[i]).get();
      Map<String, dynamic> tmpMap =
      {
        'id': userIDList[i],
        'profileIcon': document['profile_icon'],
        'nickname': document['nickname'],
        'introduction': document['introduction'],
        'profileHashtagList': document['profile_hashtag_list'],
        'userPostList': document['user_posts_list'],
      };
      //自分の情報は除外
      if( userIDList[i] != _aadm.getAccountData('id') ){
        list.add(tmpMap);
      }
    }
    return list;
  }


  //ポストIDのリストからポスト情報のリストへ変換する関数
  Future<List<Map<String, dynamic>>> getDBPostDataListFromPostIDList( List<dynamic> postIDList ) async{
    List<Map<String, dynamic>> list =[];

    for( int i=0; i<postIDList.length; i++ ){
      var document = await Firestore.instance.collection('post_info').document(postIDList[i]).get();
      Map<String, dynamic> tmpMap =
      {
        'id': postIDList[i],
        'postTitle': document['post_title'],
        'text': document['text'],
        'postUserInfo': document['post_user_info'],
        'postDate': document['post_date'],
        'postImageList': document['post_image_list'],
        'postHashtagList': document['post_hashtag_list'],
        'favoriteUserList': document['favorite_user_list'],
        'postSpot': document['spot_id'],
      };
      list.add(tmpMap);
    }
    return list;
  }




  //投稿の日時、タイトル、本文などから投稿IDを返す関数
  Future<String> getDBPostIDFromPostData( String postTitle, String text, String userId, String spotId ) async{
    String postID;

    QuerySnapshot querySnapshot = await Firestore.instance.collection('post_info').getDocuments();
    var tmp = await querySnapshot.documents;

    for( int i=0; i<tmp.length; i++ ){
      if( tmp[i]['post_title'] == postTitle
          && tmp[i]['text'] == text
          && tmp[i]['post_user_info'] == userId
          && tmp[i]['spot_id'] == spotId
      ){
        postID = tmp[i].documentID;
      }
    }
    return postID;
  }


  Future<Map<String, dynamic>> getDBSpotDataOnlyFromSpotID( String spotID ) async{
    var document = await Firestore.instance.collection('spot_info').document(spotID).get();
    Map<String, dynamic> spotInfo =
    {
      'id': spotID,
      'LocName': document['spot_name'],
      'Latitude': document['latitude'],
      'Longitude': document['longitude'],
      'PostToLoc': document['post_to_spot_list'],
      'keepSpotUserInfoList': document['keep_stop_user_info_list'],
      'haveBeenUserInfoList': document['have_been_spot_user_info_list'],
    };
    return spotInfo;
  }


  //スポットIDのリストからスポット情報のリストへ変換する関数
  Future<List<Map<String, dynamic>>> getDBSpotDataListFromSpotIDList( List<dynamic> spotIDList ) async{
    List<Map<String, dynamic>> list =[];

    for( int i=0; i<spotIDList.length; i++ ){
      var document = await Firestore.instance.collection('spot_info').document(spotIDList[i]).get();
      Map<String, dynamic> tmpMap =
      {
        'id': spotIDList[i],
        'LocName': document['spot_name'],
        'Latitude': document['latitude'],
        'Longitude': document['longitude'],
        'PostToLoc': document['post_to_spot_list'],
        'keepSpotUserInfoList': document['keep_stop_user_info_list'],
        'haveBeenUserInfoList': document['have_been_spot_user_info_list'],
      };
      list.add(tmpMap);
    }
    return list;
  }



  //スポットの名前、緯度経度からスポットIDを返す関数
  Future<String> getDBSpotIDFromSpotData( String spotName, String latitude, String longitude ) async{
    String spotID;

    QuerySnapshot querySnapshot = await Firestore.instance.collection('spot_info').getDocuments();
    var tmp = await querySnapshot.documents;

    for( int i=0; i<tmp.length; i++ ){
      if( tmp[i]['spot_name'] == spotName && tmp[i]['latitude'] == latitude && tmp[i]['longitude'] == longitude ){
        spotID = tmp[i].documentID;
      }
    }
    return spotID;
  }


  //ハッシュタグIDのリストからハッシュタグ情報のリストへ変換する関数
  //１次配列のみを取り扱う
  Future<List<Map<String, dynamic>>> getDBHashtagDataListFromHashtagIDList( List<dynamic> hashtagIDList ) async{
    List<Map<String, dynamic>> list =[];

    for( int i=0; i<hashtagIDList.length; i++ ){
      var document = await Firestore.instance.collection('hashtag_info').document(hashtagIDList[i]).get();
      Map<String, dynamic> tmpMap =
      {
        'id': hashtagIDList[i],
        'hashtag': document['hashtag'],
      };
      list.add(tmpMap);
    }
    return list;
  }



  //ハッシュタグIDのリストからハッシュタグ情報のリストへ変換する関数
  //２次元配列のみを取り扱う
  Future<List<List<Map<String, dynamic>>>> getDBHashtagDataListListFromHashtagIDListList( List<List<String>> hashtagIDListList ) async{
    List<List<Map<String, dynamic>>> list =[];
    List<Map<String, dynamic>> tmplist = [];

    //ハッシュタグIDの２次元配列の中身が空の場合は、空の２次元配列を返す。
    if( hashtagIDListList.length == 1 && hashtagIDListList.first.length == 1 ){
      if( hashtagIDListList.first.first == '' ){
        return [[]];
      }
    }

    for( int i=0; i<hashtagIDListList.length; i++ ){
      tmplist = [];
      for( int j=0; j<hashtagIDListList[i].length; j++ ){
        var document = await Firestore.instance.collection('hashtag_info').document(hashtagIDListList[i][j]).get();
        Map<String, dynamic> tmpMap =
        {
          'id': hashtagIDListList[i][j],
          'hashtag': document['hashtag'],
        };
        tmplist.add(tmpMap);
      }
      list.add(tmplist);
    }
    return list;
  }


  //ハッシュタグのリストからハッシュタグIDのリストへ変換する関数
  //ID登録されていないものが含まれる場合は、ID登録した上で取得したIDとする
  Future<List<String>> getDBHashtagIDListFromHashtagDataList( List<String> hashtagList ) async{
    List<Map<String, dynamic>> allHashtagDataList = [];
    List<String> allHashtagList = [];
    bool flag = false;

    QuerySnapshot querySnapshot = await Firestore.instance.collection('hashtag_info').getDocuments();
    var tmp = await querySnapshot.documents;

    for( int i=0; i<tmp.length; i++ ){
      Map<String, dynamic> tmpMap =
      {
        'id': tmp[i].documentID,
        'hashtag': tmp[i]['hashtag'],
      };
      allHashtagDataList.add(tmpMap);
      allHashtagList.add(tmpMap['hashtag']);
    }

    for( int j=0; j<hashtagList.length; j++ ){
      if( allHashtagList.indexOf( hashtagList[j] ) == -1 ){
        flag = true;
        await Firestore.instance.collection('hashtag_info').document()
            .setData(
            {
              'hashtag': hashtagList[j],
            });
      }
    }
    //新しくID取得が必要なハッシュタグが含まれていた場合、データを再取得。
    if( flag == true ){
      allHashtagList = [];
      allHashtagDataList = [];

      querySnapshot = await Firestore.instance.collection('hashtag_info').getDocuments();
      tmp = await querySnapshot.documents;

      for( int i=0; i<tmp.length; i++ ){
        Map<String, dynamic> tmpMap =
        {
          'id': tmp[i].documentID,
          'hashtag': tmp[i]['hashtag'],
        };
        allHashtagDataList.add(tmpMap);
        allHashtagList.add(tmpMap['hashtag']);
      }
    }

    //新規のものも含めて全てのハッシュタグにID付与されたので、ハッシュタグIDのリストを作成する
    List<String> list = [];
    for( int n=0; n<hashtagList.length; n++ ){
      for( int m=0; m<allHashtagDataList.length; m++ ){
        if( hashtagList[n] == allHashtagDataList[m]['hashtag'] ){
          list.add( allHashtagDataList[m]['id'] );
        }
      }
    }
    return list;
  }





}