
import 'package:flutter/material.dart';
import 'package:test_roketan/part/CreateButtonWidget.dart';
import 'package:test_roketan/part/DataManager.dart';

import 'package:test_roketan/part/Defines.dart' as Defines;
import 'package:test_roketan/view/MainView.dart';


class PremiumUserResister extends StatelessWidget {
  //PremiumUserResister({});

  ViewDataManager _vdm = ViewDataManager();


  @override
  Widget build(BuildContext context) {
    return Container(
      color: Defines.colorset['backgroundcolor'],
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
            child: Row(
              children: [
                CreateButtonWidget(
                  title: 'キャンセル',
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute( builder: (context) => MainView(),));
                  },
                ),
                Expanded(
                  child: Container(
                    child: Center(
                      child: RichText(
                        text: TextSpan(
                          text: 'プレミアム会員登録',
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
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute( builder: (context) => MainView(),));
                  },
                ),
              ],
            ),
          ),
          Container(
            child: Text('プレミアム会員に登録してくださーーーい'),
          ),
        ],
      ),
    );
  }
}
