

import 'dart:convert';
import 'dart:io';
import 'dart:html' as html;

import 'package:firebase/firebase.dart' as fb;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:test_roketan/part/CreateButtonWidget.dart';
import 'package:test_roketan/part/DataBase.dart';
import 'package:test_roketan/part/DataManager.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_web_image_picker/flutter_web_image_picker.dart';

import 'package:test_roketan/part/Defines.dart' as Defines;
import 'package:test_roketan/view/MainView.dart';


class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {

  //データマネージャのインスタインス生成
  ActiveAccountDataManager _aadm = new ActiveAccountDataManager();

  String _userId;
  var _profileIcon;
  String _profileIconUrl;
  String _nickname;
  String _introduction;

  String _imageFileName;
  var _imageData;

  @override
  void initState() {
    _userId = _aadm.getAccountData('id');
    _profileIconUrl = _aadm.getAccountData('profileIcon');
    _profileIcon = Image.network(_profileIconUrl).image;
    _nickname = _aadm.getAccountData('nickname');
    _introduction = _aadm.getAccountData('introduction');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Defines.colorset['backgroundcolor'],
      child: Column(
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
                    Navigator.push(context, MaterialPageRoute( builder: (context) => MainView() ));
                  },
                ),
                Expanded(
                  child: Container(
                    child: Center(
                      child: RichText(
                        text: TextSpan(
                          text: 'プロフィール編集',
                          style: TextStyle(
                              color: Defines.colorset['darkdrawcolor'],
                              fontWeight: FontWeight.normal,
                              fontSize: 24.0),
                        ),
                      ),
                    ),
                  ),
                ),
                CreateButtonWidget(
                  title: '　保存　',
                  onPressed: () async{
                    _aadm.setAccountData('nickname', _nickname);
                    _aadm.setAccountData('introduction', _introduction);
                    if( _imageFileName != null ){
                      _profileIconUrl = await DataBase().uploadAndGetUrl(_userId, _imageFileName, _imageData);
                      _aadm.setAccountData('profileIcon', _profileIconUrl);
                    }
                    Navigator.push(context, MaterialPageRoute( builder: (context) =>  MainView() ));
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              //color: Colors.cyan,
              margin: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: _profileIcon,
                        ),
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(120),
                            color: Defines.colorset['darkdrawcolor'].withOpacity(0.5),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.image_rounded,
                              size: 60,
                              color: Colors.white.withOpacity(1.0),
                            ),
                            onPressed: () async{
                              final _paths = (await FilePicker.platform.pickFiles(
                                  type: FileType.image, allowMultiple: false, withData: true))
                                  ?.files;
                              _imageFileName = _paths.first.name;
                              _imageData = _paths.first.bytes;
                              setState(() {
                                _profileIcon = Image.memory(_imageData).image;
                              });
                              //print( Image.memory(data).image );
                              //print( data.runtimeType );
                              //print( base64.encode(_paths.first.bytes) );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    //名前
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          child: RichText(
                            text: TextSpan(
                              text: '名前',
                              style: TextStyle(
                                color: Defines.colorset['drawcolor'],
                                fontWeight: FontWeight.normal,
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            child: TextFormField(
                              initialValue: _nickname,
                              style: TextStyle(height: 1.0),
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(top: 20, bottom: 20, left: 10, right: 10),
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  fontSize: 18,
                                  color: Defines.colorset['drawcolor'],
                                ),
                                filled: true, // fillColorで指定した色で塗り潰し
                                fillColor: Colors.grey[300],
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300],
                                    )
                                ),
                              ),
                              onChanged: ( String _text ){
                                _nickname = _text;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    //自己紹介
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          child: RichText(
                            text: TextSpan(
                              text: '自己紹介',
                              style: TextStyle(
                                color: Defines.colorset['drawcolor'],
                                fontWeight: FontWeight.normal,
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            child: TextFormField(
                              initialValue: _introduction,
                              style: TextStyle(height: 1.0),
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(top: 20, bottom: 20, left: 10, right: 10),
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  fontSize: 18,
                                  color: Defines.colorset['drawcolor'],
                                ),
                                filled: true, // fillColorで指定した色で塗り潰し
                                fillColor: Colors.grey[300],
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300],
                                    )
                                ),
                              ),
                              onChanged: ( String _text ){
                                _introduction = _text;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
