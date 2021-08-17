class User {
  String _uid;
  String _token;
  String _name;
  int _identity;
  String _studentId;
  String _nickName;
  String _tel;
  String _rDate;
  int _buyCount;
  int _point;
  bool _isAdmin = false;

  User(this._uid, this._token, this._name, this._identity, this._studentId,
      this._nickName, this._tel, this._rDate, this._buyCount, this._point);

  User.fromJson(Map<String, dynamic> json)
      : _uid = json['uid'],
        _token = json['token'],
        _name = json['name'],
        _identity = int.parse(json['identity']),
        _studentId = json['student_id'],
        _nickName = json['nickname'],
        _tel = json['tel'],
        _rDate = json['reg_date'],
        _buyCount = int.parse(json['buy_count']),
        _point = int.parse(json['point']);

  int get point => _point;

  set point(int value) {
    _point = value;
  }

  int get buyCount => _buyCount;

  set buyCount(int value) {
    _buyCount = value;
  }

  String get rDate => _rDate;

  set rDate(String value) {
    _rDate = value;
  }

  String get tel => _tel;

  set tel(String value) {
    _tel = value;
  }

  String get nickName => _nickName;

  set nickName(String value) {
    _nickName = value;
  }

  String get studentId => _studentId;

  set studentId(String value) {
    _studentId = value;
  }

  int get identity => _identity;

  set identity(int value) {
    _identity = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  String get token => _token;

  set token(String value) {
    _token = value;
  }

  String get uid => _uid;

  set uid(String value) {
    _uid = value;
  }

  bool get isAdmin => _isAdmin;

  set isAdmin(bool value) {
    _isAdmin = value;
  }
}
