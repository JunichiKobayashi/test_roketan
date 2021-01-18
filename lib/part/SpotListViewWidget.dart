

import 'package:flutter/material.dart';

import 'package:test_roketan/part/Defines.dart' as Defines;


class SpotListViewWidget extends StatelessWidget {
  final spotDataList;
  final Function onTapSpotNameToPostPage;
  final Function onTapPostNumberToSpotInfo;
  final Function onTapHashtagToSearchResult;
  SpotListViewWidget({
    this.spotDataList,
    this.onTapSpotNameToPostPage,
    this.onTapPostNumberToSpotInfo,
    this.onTapHashtagToSearchResult,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: spotDataList,
      builder: (context, snapshot) {
        return Container(
          child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: snapshot.hasData ? snapshot.data.length : 0,
            itemBuilder: (BuildContext context, int spotIndex) {
              return Container(
                child: Container(
                  width: double.infinity,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Defines.colorset['backgroundcolor'],
                    border: Border(
                      bottom: BorderSide(
                        color: Defines.colorset['drawcolor'],
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          //color: Colors.pinkAccent,
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: onTapSpotNameToPostPage,
                                  child: Container(
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 60.0,
                                          child: Icon(
                                            Icons.flag,
                                            color: Defines.colorset['drawcolor'],
                                            size: 40.0,
                                          ),
                                        ),
                                        Expanded(
                                          child: RichText(
                                            text: TextSpan(
                                              text: snapshot.hasData ? snapshot.data[spotIndex]['LocName'] : '',
                                              style: TextStyle(
                                                fontSize: 28.0,
                                                fontWeight: FontWeight.bold,
                                                color: Defines.colorset['darkdrawcolor'],
                                              ),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: onTapPostNumberToSpotInfo,
                                child: Container(
                                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                                  child: Row(
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          text: snapshot.hasData ? snapshot.data[spotIndex]['PostToLoc'].length.toString() : '',
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold,
                                            color: Defines.colorset['darkdrawcolor'],
                                          ),
                                        ),
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          text: ' 件の投稿',
                                          style: TextStyle(
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.normal,
                                            color: Defines.colorset['drawcolor'],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        height: 36,
                        width: double.infinity,
                        //color: Colors.deepPurpleAccent,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.hasData ? snapshot.data[spotIndex]['hashtagList'].length : 0,
                          itemBuilder: (BuildContext context, int hashtagIndex) {
                            return GestureDetector(
                              onTap: onTapHashtagToSearchResult,
                              child: Container(
                                padding: EdgeInsets.only(right: 8.0, bottom: 12.0),
                                height: 10,
                                child: Container(
                                  padding: EdgeInsets.only(left: 8.0, right: 8.0),
                                  decoration: BoxDecoration(
                                    color: Defines.colorset['drawcolor'],
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  child: Center(
                                    child: Text(
                                      snapshot.hasData
                                          ? snapshot.data[spotIndex]['hashtagList'][hashtagIndex]
                                          : '',
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }
    );
  }
}
