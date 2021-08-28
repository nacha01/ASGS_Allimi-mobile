import 'package:asgshighschool/data/user_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StoreMyPage extends StatefulWidget {
  StoreMyPage({this.user});
  User user;
  @override
  _StoreMyPageState createState() => _StoreMyPageState();
}
/* 마이페이지 */

// 닉네임 변경
// 신분 변경
// 전화번호 변경 기능?

class _StoreMyPageState extends State<StoreMyPage> {
  final statusReverseList = ['재학생', '학부모', '교사', '졸업생', '기타'];
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(5),
                margin: EdgeInsets.all(10),
                child: Text(
                  '마이페이지',
                  style: TextStyle(
                      color: Color(0xFF9EE1E5),
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: EdgeInsets.all(5),
                margin: EdgeInsets.all(5),
                child: Row(
                  children: [
                    Container(
                      width: size.width * 0.95,
                      child: Card(
                        child: ListTile(
                          leading: Container(
                            width: size.width * 0.2,
                            height: size.height * 0.075,
                            child: Image(
                              image: AssetImage('assets/images/asgs_mark.png'),
                              fit: BoxFit.fill,
                            ),
                          ),
                          title: Text(
                              statusReverseList[widget.user.identity - 1] +
                                  ' ' +
                                  (widget.user.isAdmin ? '[관리자] ' : '')),
                          subtitle: Text(
                              '${widget.user.nickName} ${widget.user.studentId == null ? '' : widget.user.studentId} [${widget.user.name}]'),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(5),
                alignment: Alignment.centerLeft,
                child: Text(
                  '쇼핑',
                  style: TextStyle(color: Color(0xFF9EE1E5), fontSize: 17),
                ),
              ),
              Container(
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
                      style: TextStyle(fontSize: 19),
                    )
                  ],
                ),
              ),
              dividerForContents(),
              Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(5),
                child: Row(
                  children: [
                    Text(
                      '활동',
                      style: TextStyle(color: Color(0xFF9EE1E5), fontSize: 17),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(5),
                child: Row(
                  children: [
                    Icon(Icons.chat,
                        color: Colors.grey, size: size.width * 0.1),
                    SizedBox(
                      width: size.width * 0.03,
                    ),
                    Text('문의 내역', style: TextStyle(fontSize: 19))
                  ],
                ),
              ),
              dividerForContents(),
              Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(5),
                child: Row(
                  children: [
                    Text(
                      '기타',
                      style: TextStyle(color: Color(0xFF9EE1E5), fontSize: 17),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(5),
                child: Row(
                  children: [
                    Icon(Icons.settings,
                        color: Colors.grey, size: size.width * 0.1),
                    SizedBox(
                      width: size.width * 0.03,
                    ),
                    Text('설정', style: TextStyle(fontSize: 19))
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(5),
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
              widget.user.isAdmin
                  ? Column(
                      children: [
                        dividerForContents(),
                        Container(
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.all(5),
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
                        Container(
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.all(5),
                          child: Row(
                            children: [
                              Icon(Icons.settings,
                                  color: Colors.grey, size: size.width * 0.1),
                              SizedBox(
                                width: size.width * 0.03,
                              ),
                              Text('관리자 설정', style: TextStyle(fontSize: 19))
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.all(5),
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
                        Container(
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.all(5),
                          child: Row(
                            children: [
                              Container(

                                  child: Image.asset(
                                      'assets/images/log_image.jpg'),
                              width: size.width * 0.1,
                              height: size.height * 0.04,),
                              SizedBox(
                                width: size.width * 0.03,
                              ),
                              Text('로그 확인하기', style: TextStyle(fontSize: 19))
                            ],
                          ),
                        ),
                      ],
                    )
                  : SizedBox()
            ],
          ),
        ),
      ),
    );
  }

  Widget dividerForContents() {
    return Divider(
      color: Color(0xFF9EE1E5),
      indent: 15,
      endIndent: 15,
      thickness: 2,
    );
  }
}
