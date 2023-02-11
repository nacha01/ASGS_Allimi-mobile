import 'package:asgshighschool/component/CorporationComp.dart';
import 'package:asgshighschool/component/DefaultButtonComp.dart';

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
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StoreMyPage extends StatefulWidget {
  StoreMyPage({this.user});

  final User? user;

  @override
  _StoreMyPageState createState() => _StoreMyPageState();
}

class _StoreMyPageState extends State<StoreMyPage> {
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
                  DefaultButtonComp(
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
                      width: size.width * 0.95,
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
                              Status.statusList[data.user!.identity - 1] +
                                  ' ' +
                                  (data.user!.isAdmin ? '[관리자] ' : '')),
                          subtitle: Text(
                              '${data.user!.nickName} ${data.user!.studentId == null ? '' : data.user!.studentId} [${data.user!.name}]'),
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
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
              DefaultButtonComp(
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
                      Text('내 주문 현황', style: TextStyle(fontSize: 17))
                    ],
                  ),
                ),
              ),
              DefaultButtonComp(
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
                      Text('내 예약 현황', style: TextStyle(fontSize: 17))
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
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              DefaultButtonComp(
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
                      Text('내 문의 내역', style: TextStyle(fontSize: 17))
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
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              DefaultButtonComp(
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
                      Text('문의하기', style: TextStyle(fontSize: 17))
                    ],
                  ),
                ),
              ),
              if (data.user!.isAdmin)
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
                                color: Colors.red,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                    DefaultButtonComp(
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
                              Text('주문 현황 목록',
                                  style: TextStyle(
                                    fontSize: 17,
                                  ))
                            ],
                          ),
                        )),
                    DefaultButtonComp(
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
                            Text('문의 목록', style: TextStyle(fontSize: 17))
                          ],
                        ),
                      ),
                    ),
                    DefaultButtonComp(
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
                            Text('예약 목록', style: TextStyle(fontSize: 17))
                          ],
                        ),
                      ),
                    ),
                    DefaultButtonComp(
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
                              Text('푸시 알림 보내기', style: TextStyle(fontSize: 17))
                            ],
                          ),
                        )),
                    DefaultButtonComp(
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
                            Text('통계', style: TextStyle(fontSize: 17))
                          ],
                        ),
                      ),
                    )
                  ],
                )
              else
                SizedBox(),
              CorporationInfo(isOpenable: false)
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
}
