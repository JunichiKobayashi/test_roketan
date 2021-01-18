

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:test_roketan/page/NarrowDownByHashtag.dart';
import 'package:test_roketan/part/Defines.dart' as Defines;

import 'Hashtag.dart';



class SetHashtagWidget extends StatefulWidget {
  final int index;
  final List<String> hashtagList;
  final Function onSubmitHashtag;
  final Function onTapClearButton;
  SetHashtagWidget({
    this.index,
    this.hashtagList,
    this.onSubmitHashtag,
    this.onTapClearButton,
  });

  @override
  _SetHashtagWidgetState createState() => _SetHashtagWidgetState();
}

class _SetHashtagWidgetState extends State<SetHashtagWidget> {
  suggestCreator _suggest;
  List<String> suggestData;
  List<String> userHashtagList;

  // AutoComplete機能
  String currentText = "";
  GlobalKey<AutoCompleteTextFieldState<String>> autoCompleteKey = new GlobalKey();

  SimpleAutoCompleteTextField textField;

  initState() {
    super.initState();
  }

  _SetHashtagWidgetState() {
    _suggest = new suggestCreator();
    _suggest.setHashtagDB();

    _initSuggestData(userHashtagList);

    textField = SimpleAutoCompleteTextField(
      key: autoCompleteKey,
      controller: TextEditingController(text: ""),
      suggestions: suggestData,
      textChanged: (text) => currentText = text,
      clearOnSubmit: true,
      textSubmitted: (text) => _addHashtagList(text),
    );
  }

  void _addHashtagList(String text) async {

    if (text == "") {
      textField.updateDecoration(
          decoration: new InputDecoration(errorText: "空白は追加できません")
      );
      return;
    }

    if (userHashtagList.indexOf(text) != -1) {
      textField.updateDecoration(
          decoration: new InputDecoration(errorText: "入力した単語はすでに登録されています")
      );
      return;
    }

    // 追加成功
    textField.updateDecoration(
        decoration: new InputDecoration(errorText: null,)
    );

    setState(() {
      userHashtagList.add(text);
      widget.onSubmitHashtag(text);
    });

    await _suggest.setUserHashtag(userHashtagList);


    await _suggest.setSuggestData();
    setState(() {
      suggestData = _suggest.getSuggestData;
    });

    textField.updateSuggestions(suggestData);
  }

  void _initSuggestData(List<String> hashtagListData) async {
    await _suggest.setUserHashtag(hashtagListData);

    await _suggest.setSuggestData();

    textField.updateSuggestions(_suggest.getSuggestData);

    setState(() {
      userHashtagList = _suggest.getUserHashtag;
      suggestData = _suggest.getSuggestData;
    });

  }

  @override
  Widget build(BuildContext context) {

    userHashtagList = widget.hashtagList;

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.index <= 0 ? Container() :Container(
            width: double.infinity,
            height: 3,
            color: Defines.colorset['drawcolor'],
            margin: EdgeInsets.symmetric(vertical: 10),
          ),
          Container(
            margin: EdgeInsets.only(left: 4),
            child: widget.index != -100
                ? Text(
                    '条件${widget.index+1}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  )
                :Text(
                  'ハッシュタグを入力してください',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                    color: Defines.colorset['drawcolor'],
                  ),
            ),
          ),
          Container(
            //color: Defines.colorset['backgroundcolor'],
            child: ListTile(
              title: textField,
              trailing: RaisedButton(
                child: RichText(
                  text: TextSpan(
                    text: '追加',
                    style: TextStyle(
                        color: Defines.colorset['drawcolor']),
                  ),
                ),
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    color: Defines.colorset['drawcolor'],
                  ),
                ),
                color: Defines.colorset['backgroundcolor'],
                onPressed: () {
                  textField.triggerSubmitted();
                },
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    children: hashtagListCreator(userHashtagList),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(right: 6),
                  child: RaisedButton(
                    child: RichText(
                      text: TextSpan(
                        text: 'クリア',
                        style: TextStyle(
                            color: Defines.colorset['drawcolor']),
                      ),
                    ),
                    shape: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Defines.colorset['drawcolor'],
                      ),
                    ),
                    color: Defines.colorset['backgroundcolor'],
                    onPressed: () {
                      widget.onTapClearButton();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}