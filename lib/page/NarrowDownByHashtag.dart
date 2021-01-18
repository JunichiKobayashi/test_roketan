import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:test_roketan/part/CreateButtonWidget.dart';
import 'package:test_roketan/part/DataBase.dart';
import 'package:test_roketan/part/DataManager.dart';
import 'package:test_roketan/part/Defines.dart' as Defines;
import 'package:test_roketan/part/Hashtag.dart';
import 'package:test_roketan/part/SetHashtagWidget.dart';
import 'package:test_roketan/view/MainView.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:list_diff/list_diff.dart';

class NarrowDownByHashtag extends StatefulWidget {
  @override
  _NarrowDownByHashtagState createState() => _NarrowDownByHashtagState();
}

class _NarrowDownByHashtagState extends State<NarrowDownByHashtag> {

  ViewDataManager _vdm = new ViewDataManager();
  ActiveAccountDataManager _aadm = new ActiveAccountDataManager();
  AppDataManager _appdm = new AppDataManager();

  List<List<String>> _userHashtagIDList;
  List<List<String>> _userHashtagList;

  bool _offstageCaution = true;

  bool setOffstage(int index){
    if( _aadm.getAccountData('isPremium') == true ){
      //条件追加は３つまで
      if( index < 3 ){
        return false;
      }
    } else {
      if( index == 0 ){
        return false;
      }
    }
    return true;
  }

  //ハッシュタグの２次元配列を渡し、ハッシュタグIDの２次元配列を返すメソッド
  //条件nのハッシュタグデータが空の場合、条件nを削除して整える
  Future<List<List<String>>> newHashtagResister( List<List<String>> hashtagList ) async{
    //条件nのハッシュタグデータが空の場合、条件nを削除して整える
    // [ [], [A, B], [C] ] 　→　[ [A, B], [ C ]
    dynamic _data = hashtagList;
    for( int i=0; i<_data.length; i++ ){
      if( _data[i].length == 0 ){
        _data.removeAt(i);
        i--;
      }
    }
    //全部空っぽになったら[ [''] ]を返す
    if( _data.length == 0 ){
      return [['']];
    }
    //ハッシュタグデータの２次元を１次元に並べる
    List<String> tmplist = [];
    for( int i=0; i<_data.length; i++ ){
      for( int j=0; j<_data[i].length; j++ ){
        //重複OK [ A, B, C, A, D ] でもOK
        tmplist.add( _data[i][j] );
      }
    }
    //ハッシュタグのリストを引数として渡し、IDのリストを返す
    //登録されていないハッシュタグが含まれている場合は、ID登録した上で新たに取得したIDとする
    List<String> hashtagIDList = await DataBase().getDBHashtagIDListFromHashtagDataList( tmplist );
    //１次元配列を２次元配列に戻す
    // [ A, B, C, D, E ] → [ [A, B, C], [D, E] ]
    List<String> tlist = [];
    List<List<String>> list = [];
    int index = 0;
    for( int n=0; n<_data.length; n++ ){
      tlist = [];
      for( int m=0; m<_data[n].length; m++ ){
        tlist.add( hashtagIDList[index] );
        index++;
      }
      list.add( tlist );
    }
    return list;
  }

  //ハッシュタグの２次元データを引数として渡し、プロフィール用に１次元に整理して返す。
  //ハッシュタグデータが空の場合、空のリストを返す
  List<String> arrangeHashtagID ( List<List<String>> hashtagDim2 ) {
    List<String> hashtagDim1 = [];
    for( int i=0; i<hashtagDim2.length; i++ ){
      for( int j=0; j<hashtagDim2[i].length; j++ ){
        if( hashtagDim1.indexOf( hashtagDim2[i][j] ) == -1 ){
          hashtagDim1.add( hashtagDim2[i][j] );
        }
      }
    }
    return hashtagDim1;
  }

  @override
  void initState() {
    Future(() async {
      _userHashtagIDList = _aadm.getAccountData('narrowDownHashtagList');
      var tmpList = await DataBase().getDBHashtagDataListListFromHashtagIDListList( _userHashtagIDList );
      List<String> tmp = [];
      _userHashtagList = [];
      for( int i=0; i<tmpList.length; i++ ){
        tmp = [];
        for( int j=0; j<tmpList[i].length; j++ ){
          tmp.add( tmpList[i][j]['hashtag'] );
        }
        _userHashtagList.add(tmp);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          Column(
            children: [
              Container(
                height: 60.0,
                decoration: BoxDecoration(
                  color: Defines.colorset['backgroundcolor'],
                  border: Border(
                    bottom: BorderSide(
                      color: Defines.colorset['drawcolor'],
                      width: 1.0,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    CreateButtonWidget(
                      title: 'キャンセル',
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => MainView() ));
                      },
                    ),
                    Expanded(
                      child: Container(
                        /*
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CreateNarrowDownResultNumberViewWidget(
                              title: '聖地',
                              number: _resultSpotNumber,
                            ),
                            CreateNarrowDownResultNumberViewWidget(
                              title: '投稿',
                              number: _resultPostNumber,
                            ),
                          ],
                        ),
                        */
                      ),
                    ),
                    CreateButtonWidget(
                      title: '　保存　',
                      onPressed: () async{

                        //保存ボタンを押した時に、データベースに登録されていないものはIDを取得した上で
                        //IDのリスト（２次元）を返す
                        List<List<String>> narrowDownList = await newHashtagResister( _userHashtagList );
                        List<String> profileList = arrangeHashtagID( narrowDownList );

                        _aadm.setAccountData('profileHashtagList', profileList);
                        _aadm.setAccountData('narrowDownHashtagList',narrowDownList );

                        Navigator.push(context, MaterialPageRoute(builder: (context) => MainView() ));
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(top: 20.0, bottom: 10, left: 4, right: 4),
                  width: double.infinity,
                  color: Defines.colorset['backgroundcolor'],
                  child: ListView.builder(
                    itemCount: _userHashtagList == null ? 0 : _userHashtagList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Offstage(
                          offstage: setOffstage( index ),
                          child: SetHashtagWidget(
                            index: index,
                            hashtagList: _userHashtagList[index],
                            onSubmitHashtag: (String str){},
                            onTapClearButton: (){
                              if( _userHashtagList[index].length != 0 ){
                                setState(() {
                                  _userHashtagList[index].removeAt( _userHashtagList[index].length -1 );
                                });
                              }
                            },
                          ),
                        );
                      },
                  ),
                ),
              ),
            ],
          ),
          Container(
            alignment: Alignment.bottomRight,
            margin: EdgeInsets.all(15),
            child: Container(
              width: 100,
              height: 40,
              child: RaisedButton(
                child: Text(
                  '条件追加',
                  style: TextStyle(
                    fontWeight: _aadm.getAccountData('isPremium') == true
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: _aadm.getAccountData('isPremium') == true
                        ? Defines.colorset['backgroundcolor']
                        : Defines.colorset['drawcolor'],
                  ),
                ),
                color: _aadm.getAccountData('isPremium') == true
                    ? Defines.colorset['highlightcolor']
                    : Defines.colorset['backgroundcolor'],
                shape: StadiumBorder(),
                onPressed: () {
                  if( _aadm.getAccountData('isPremium') == true ){
                    setState(() {
                      _userHashtagList.add([]);
                    });
                  } else {
                    setState(() {
                      _offstageCaution = false;
                    });
                  }
                },
              ),
            ),
          ),
          Offstage(
            offstage: _offstageCaution,
            child: Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: 60,
                color: Colors.grey[300].withOpacity(0.8),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          'プレミアム会員登録すると条件3まで登録できます',
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
          ),
        ],
      ),
    );
  }
}

class CreateNarrowDownResultNumberViewWidget extends StatelessWidget {
  final String title;
  final int number;

  CreateNarrowDownResultNumberViewWidget({
    this.title,
    this.number,
  });

  final formatter = NumberFormat('#,##0', 'ja_JP');

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          RichText(
            text: TextSpan(
              text: title + ' ',
              style: TextStyle(
                  color: Defines.colorset['drawcolor'], fontSize: 14.0),
            ),
          ),
          RichText(
            text: TextSpan(
              text: formatter.format(number).toString(),
              style: TextStyle(
                  color: Defines.colorset['darkdrawcolor'], fontSize: 18.0),
            ),
          ),
          RichText(
            text: TextSpan(
              text: ' 件',
              style: TextStyle(
                  color: Defines.colorset['drawcolor'], fontSize: 14.0),
            ),
          ),
        ],
      ),
    );
  }
}


class suggestCreator {

  suggestCreator() {
    setHashtagDB();
  }

  List<String> _userHashtag;
  List<String> _hashtagDB;
  List<String> _suggestData;

  List<String> get getUserHashtag => _userHashtag;
  List<String> get getHashtagDB => _hashtagDB;
  List<String> get getSuggestData => _suggestData;

  void setUserHashtag(List<String> argUserHashtag) => this._userHashtag = argUserHashtag;

  void setHashtagDB() async{
    // 仮データ >> DBから取得に変更? //
    List<Map<String, dynamic>> hashtagMapAll = await DataBase().getDBHashtagData();
    List<String> list = [];
    for( int i=0; i<hashtagMapAll.length; i++ ){
      list.add( hashtagMapAll[i]['hashtag'] );
    }
    List<String> _dbData = list.toSet().toList();
    ///////////////////////////////
    this._hashtagDB  = _dbData;
  }

  void setSuggestData() async {
    await setHashtagDB();

    this._suggestData = List<String>();

    /*
    List<String> _tmpSuggestData = List<String>();
    List<Operation<String>> _diffData = List<Operation<String>>();
    _diffData = await diff(this._userHashtag, this._hashtagDB);
    for (var diffDataOne in _diffData) {
      diffDataOne.applyTo(_tmpSuggestData);
    }
    this._suggestData = _tmpSuggestData;
     */

    this._suggestData = this._hashtagDB;
  }

}