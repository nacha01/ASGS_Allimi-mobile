import 'dart:ui';

import '../data/provider/renew_user.dart';
import 'package:asgshighschool/data/status.dart';
import 'package:asgshighschool/data/user.dart';
import 'package:asgshighschool/store/InquirePage.dart';
import 'package:asgshighschool/store/MyQnAPage.dart';
import 'package:asgshighschool/store/OrderStatePage.dart';
import 'package:asgshighschool/store/ReservationStatePage.dart';
import 'package:asgshighschool/store/UpdateUserPage.dart';
import '../storeAdmin/order/OrderListPage.dart';
import 'package:asgshighschool/storeAdmin/PushNotificationPage.dart';
import '../storeAdmin/post/QnAListPage.dart';
import '../storeAdmin/reservation/ReservationListPage.dart';
import '../storeAdmin/statistics/StatisticsPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StoreMyPage extends StatefulWidget {
  StoreMyPage({this.user});

  final User user;

  @override
  _StoreMyPageState createState() => _StoreMyPageState();
}
/* 마이페이지 */

// 닉네임 변경
// 신분 변경
// 전화번호 변경 기능?

class _StoreMyPageState extends State<StoreMyPage> {
  @override
  void initState() {
    super.initState();
  }

  /// 미구현 메뉴 클릭 시 띄워주는 dialog
  void _dialogNotImplement() {
    showDialog(
        context: context,
        builder: (ctx) {
          Future.delayed(Duration(milliseconds: 500), () {
            Navigator.pop(ctx);
          });
          return AlertDialog(
            shape: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            content: Text(
              '준비중 입니다...',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final data = Provider.of<RenewUserData>(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.all(size.width * 0.03),
                    margin: EdgeInsets.all(size.width * 0.01),
                    child: Text(
                      '마이페이지',
                      style: TextStyle(
                          color: Color(0xFF9EE1E5),
                          fontSize: 28,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.keyboard_return,
                          color: Colors.deepOrange,
                        ),
                        SizedBox(
                          width: size.width * 0.008,
                        ),
                        Text(
                          '알리미로 돌아가기',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange),
                        )
                      ],
                    ),
                  )
                ],
              ),
              Container(
                padding: EdgeInsets.all(size.width * 0.01),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: size.width * 0.9,
                      child: Card(
                        child: ListTile(
                          onTap: () async {
                            final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => UpdateUserPage(
                                          user: data.user,
                                        )));
                          },
                          leading: Container(
                            width: size.width * 0.2,
                            height: size.height * 0.075,
                            child: Image(
                              image: AssetImage('assets/images/asgs_mark.png'),
                              fit: BoxFit.fill,
                            ),
                          ),
                          title: Text(
                              Status.statusList[data.user.identity - 1] +
                                  ' ' +
                                  (data.user.isAdmin ? '[관리자] ' : '')),
                          subtitle: Text(
                              '${data.user.nickName} ${data.user.studentId == null ? '' : data.user.studentId} [${data.user.name}]'),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(size.width * 0.01),
                padding: EdgeInsets.all(size.width * 0.01),
                alignment: Alignment.centerLeft,
                child: Text(
                  '쇼핑',
                  style: TextStyle(color: Color(0xFF9EE1E5), fontSize: 17),
                ),
              ),
              /*FlatButton(
                onPressed: () {
                  _dialogNotImplement();
                },
                child: Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(5),
                  child: Row(
                    children: [
                      Icon(Icons.shopping_bag,
                          color: Colors.grey, size: size.width * 0.1),
                      SizedBox(
                        width: size.width * 0.03,
                      ),
                      Text(
                        '최근 본 상품',
                        style: TextStyle(fontSize: 19, color: Colors.grey),
                      )
                    ],
                  ),
                ),
              ),
              */
              FlatButton(
                padding: EdgeInsets.all(size.width * 0.015),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => OrderStatePage(
                                user: widget.user,
                              )));
                },
                child: Container(
                  margin: EdgeInsets.all(size.width * 0.01),
                  padding: EdgeInsets.all(size.width * 0.01),
                  child: Row(
                    children: [
                      Icon(Icons.delivery_dining,
                          color: Colors.grey, size: size.width * 0.1),
                      SizedBox(
                        width: size.width * 0.03,
                      ),
                      Text('내 주문 현황', style: TextStyle(fontSize: 19))
                    ],
                  ),
                ),
              ),
              FlatButton(
                padding: EdgeInsets.all(size.width * 0.015),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ReservationStatePage(
                                user: widget.user,
                              )));
                },
                child: Container(
                  margin: EdgeInsets.all(size.width * 0.01),
                  padding: EdgeInsets.all(size.width * 0.01),
                  child: Row(
                    children: [
                      Icon(Icons.event_available_outlined,
                          color: Colors.grey, size: size.width * 0.1),
                      SizedBox(
                        width: size.width * 0.03,
                      ),
                      Text('내 예약 현황', style: TextStyle(fontSize: 19))
                    ],
                  ),
                ),
              ),
              dividerForContents(size),
              Container(
                margin: EdgeInsets.all(size.width * 0.01),
                padding: EdgeInsets.all(size.width * 0.01),
                child: Row(
                  children: [
                    Text(
                      '활동',
                      style: TextStyle(color: Color(0xFF9EE1E5), fontSize: 17),
                    )
                  ],
                ),
              ),
              FlatButton(
                padding: EdgeInsets.all(size.width * 0.015),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MyQnAPage(
                                user: widget.user,
                              )));
                },
                child: Container(
                  margin: EdgeInsets.all(size.width * 0.01),
                  padding: EdgeInsets.all(size.width * 0.01),
                  child: Row(
                    children: [
                      Icon(Icons.chat,
                          color: Colors.grey, size: size.width * 0.1),
                      SizedBox(
                        width: size.width * 0.03,
                      ),
                      Text('내 문의 내역', style: TextStyle(fontSize: 19))
                    ],
                  ),
                ),
              ),
              dividerForContents(size),
              Container(
                margin: EdgeInsets.all(size.width * 0.01),
                padding: EdgeInsets.all(size.width * 0.01),
                child: Row(
                  children: [
                    Text(
                      '기타',
                      style: TextStyle(color: Color(0xFF9EE1E5), fontSize: 17),
                    )
                  ],
                ),
              ),
              /*FlatButton(
                onPressed: () {
                  _dialogNotImplement();
                },
                child: Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(5),
                  child: Row(
                    children: [
                      Icon(Icons.settings,
                          color: Colors.grey, size: size.width * 0.1),
                      SizedBox(
                        width: size.width * 0.03,
                      ),
                      Text('설정',
                          style: TextStyle(fontSize: 19, color: Colors.grey))
                    ],
                  ),
                ),
              ),
               */
              FlatButton(
                padding: EdgeInsets.all(size.width * 0.015),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => InquirePage(
                                user: widget.user,
                              )));
                },
                child: Container(
                  margin: EdgeInsets.all(size.width * 0.01),
                  padding: EdgeInsets.all(size.width * 0.01),
                  child: Row(
                    children: [
                      Icon(Icons.headset_mic_outlined,
                          color: Colors.grey, size: size.width * 0.1),
                      SizedBox(
                        width: size.width * 0.03,
                      ),
                      Text('문의하기', style: TextStyle(fontSize: 19))
                    ],
                  ),
                ),
              ),
              if (data.user.isAdmin)
                Column(
                  children: [
                    dividerForContents(size),
                    Container(
                      margin: EdgeInsets.all(size.width * 0.01),
                      padding: EdgeInsets.all(size.width * 0.01),
                      child: Row(
                        children: [
                          Text(
                            '관리자',
                            style: TextStyle(
                                color: Colors.redAccent, fontSize: 17),
                          )
                        ],
                      ),
                    ),
                    /* FlatButton(
                      onPressed: () {
                        _dialogNotImplement();
                      },
                      child: Container(
                        margin: EdgeInsets.all(10),
                        padding: EdgeInsets.all(5),
                        child: Row(
                          children: [
                            Icon(Icons.settings,
                                color: Colors.grey, size: size.width * 0.1),
                            SizedBox(
                              width: size.width * 0.03,
                            ),
                            Text('관리자 설정',
                                style:
                                    TextStyle(fontSize: 19, color: Colors.grey))
                          ],
                        ),
                      ),
                    ),

                    */
                    /*FlatButton(
                      onPressed: () {
                        _dialogNotImplement();
                      },
                      child: Container(
                        margin: EdgeInsets.all(10),
                        padding: EdgeInsets.all(5),
                        child: Row(
                          children: [
                            Icon(Icons.bar_chart,
                                color: Colors.grey, size: size.width * 0.1),
                            SizedBox(
                              width: size.width * 0.03,
                            ),
                            Text('통계',
                                style:
                                    TextStyle(fontSize: 19, color: Colors.grey))
                          ],
                        ),
                      ),
                    ),

                     */
                    FlatButton(
                      padding: EdgeInsets.all(size.width * 0.015),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => OrderListPage(
                                      user: widget.user,
                                    )));
                      },
                      child: Container(
                        margin: EdgeInsets.all(size.width * 0.01),
                        padding: EdgeInsets.all(size.width * 0.01),
                        child: Row(
                          children: [
                            Icon(Icons.timer,
                                color: Colors.grey, size: size.width * 0.1),
                            SizedBox(
                              width: size.width * 0.03,
                            ),
                            Text('실시간 주문(구매) 현황 목록',
                                style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepOrangeAccent))
                          ],
                        ),
                      ),
                    ),
                    /*FlatButton(
                      onPressed: () {
                        _dialogNotImplement();
                      },
                      child: Container(
                        margin: EdgeInsets.all(10),
                        padding: EdgeInsets.all(5),
                        child: Row(
                          children: [
                            Icon(Icons.add_shopping_cart,
                                color: Colors.grey, size: size.width * 0.1),
                            SizedBox(
                              width: size.width * 0.03,
                            ),
                            Text('상품 입고 작성',
                                style:
                                    TextStyle(fontSize: 19, color: Colors.grey))
                          ],
                        ),
                      ),
                    ),
                     */
                    FlatButton(
                      padding: EdgeInsets.all(size.width * 0.015),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => QnAListPage(
                                      user: widget.user,
                                    )));
                      },
                      child: Container(
                        margin: EdgeInsets.all(size.width * 0.01),
                        padding: EdgeInsets.all(size.width * 0.01),
                        child: Row(
                          children: [
                            Icon(Icons.mark_chat_unread,
                                color: Colors.grey, size: size.width * 0.1),
                            SizedBox(
                              width: size.width * 0.03,
                            ),
                            Text('문의 목록', style: TextStyle(fontSize: 19))
                          ],
                        ),
                      ),
                    ),
                    FlatButton(
                      padding: EdgeInsets.all(size.width * 0.015),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ReservationListPage(
                                      user: widget.user,
                                    )));
                      },
                      child: Container(
                        margin: EdgeInsets.all(size.width * 0.01),
                        padding: EdgeInsets.all(size.width * 0.01),
                        child: Row(
                          children: [
                            Icon(Icons.event_note,
                                color: Colors.grey, size: size.width * 0.1),
                            SizedBox(
                              width: size.width * 0.03,
                            ),
                            Text('예약 목록', style: TextStyle(fontSize: 19))
                          ],
                        ),
                      ),
                    ),
                    FlatButton(
                      padding: EdgeInsets.all(size.width * 0.015),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PushNotificationPage(
                                      user: widget.user,
                                    )));
                      },
                      child: Container(
                        margin: EdgeInsets.all(size.width * 0.01),
                        padding: EdgeInsets.all(size.width * 0.01),
                        child: Row(
                          children: [
                            Icon(Icons.notifications_active,
                                color: Colors.grey, size: size.width * 0.1),
                            SizedBox(
                              width: size.width * 0.03,
                            ),
                            Text('푸시 알림 보내기', style: TextStyle(fontSize: 19))
                          ],
                        ),
                      ),
                    ),
                    FlatButton(
                      padding: EdgeInsets.all(size.width * 0.015),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => StatisticsPage(
                                      user: widget.user,
                                    )));
                      },
                      child: Container(
                        margin: EdgeInsets.all(size.width * 0.01),
                        padding: EdgeInsets.all(size.width * 0.01),
                        child: Row(
                          children: [
                            Icon(Icons.bar_chart,
                                color: Colors.grey, size: size.width * 0.1),
                            SizedBox(
                              width: size.width * 0.03,
                            ),
                            Text('통계', style: TextStyle(fontSize: 19))
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              else
                SizedBox(),
              _corpInfoLayout(size)
            ],
          ),
        ),
      ),
    );
  }

  Widget dividerForContents(Size size) {
    return Divider(
      color: Color(0xFF9EE1E5),
      indent: size.width * 0.04,
      endIndent: size.width * 0.04,
      thickness: 2,
    );
  }

  Widget _corpInfoLayout(Size size) {
    return Container(
      width: size.width,
      padding: EdgeInsets.all(size.width * 0.02),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '회사 정보',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
          ),
          SizedBox(
            height: size.height * 0.005,
          ),
          Text(
            '사업자 번호: 135-82-17822',
            style: TextStyle(color: Colors.grey, fontSize: 9),
          ),
          Text('회사명: 안산강서고등학교 교육경제공동체 사회적협동조합',
              style: TextStyle(color: Colors.grey, fontSize: 9)),
          Text('대표자: 김은미', style: TextStyle(color: Colors.grey, fontSize: 9)),
          Text('위치: 경기도 안산시 단원구 와동 삼일로 367, 5층 공작관 다목적실 (안산강서고등학교)',
              style: TextStyle(color: Colors.grey, fontSize: 9)),
          Text('대표 전화: 031-485-9742',
              style: TextStyle(color: Colors.grey, fontSize: 9)),
          Text('대표 이메일: asgscoop@naver.com',
              style: TextStyle(color: Colors.grey, fontSize: 9))
        ],
      ),
    );
  }
}
