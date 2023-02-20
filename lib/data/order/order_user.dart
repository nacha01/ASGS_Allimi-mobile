class OrderUser {
  String userID;
  String name;
  int identity;
  String? studentID;
  String nickname;

  OrderUser(
      this.userID, this.name, this.identity, this.studentID, this.nickname);

  OrderUser.fromJson(Map<String, dynamic> json)
      : userID = json['uID'],
        name = json['name'],
        identity = int.parse(json['identity']),
        studentID =
            int.parse(json['identity']) == 1 ? json['student_id'] : null,
        nickname = json['nickname'];
}
