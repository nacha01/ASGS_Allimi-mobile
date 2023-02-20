class User {
  String? uid;
  String? token;
  String? name;
  int identity;
  String? studentId;
  String? nickName;
  String? rDate;
  int buyCount;
  int point;
  bool isAdmin = false;
  String? adminKey;
  String? email = '';

  User(this.uid, this.token, this.name, this.identity, this.studentId,
      this.nickName, this.rDate, this.buyCount, this.point, this.email);

  User.empty()
      : uid = "",
        token = "",
        name = "",
        identity = 1,
        studentId = "",
        nickName = "",
        rDate = "",
        buyCount = 0,
        point = 0;

  User.fromJson(Map<String, dynamic> json)
      : uid = json['uid'],
        token = json['token'],
        name = json['name'],
        identity = int.parse(json['identity']),
        studentId = json['student_id'],
        nickName = json['nickname'],
        rDate = json['reg_date'],
        buyCount = int.parse(json['buy_count']),
        point = int.parse(json['point']),
        email = json['email'];
}
