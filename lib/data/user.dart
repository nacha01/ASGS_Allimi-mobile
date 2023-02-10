class User {
  String? _uid;
  String? _token;
  String? _name;
  int _identity;
  String? _studentId;
  String? _nickName;
  String? _rDate;
  int _buyCount;
  int _point;
  bool _isAdmin = false;
  String? _adminKey;
  String? _email = '';

  User(this._uid, this._token, this._name, this._identity, this._studentId,
      this._nickName, this._rDate, this._buyCount, this._point, this._email);

  User.fromJson(Map<String, dynamic> json)
      : _uid = json['uid'],
        _token = json['token'],
        _name = json['name'],
        _identity = int.parse(json['identity']),
        _studentId = json['student_id'],
        _nickName = json['nickname'],
        _rDate = json['reg_date'],
        _buyCount = int.parse(json['buy_count']),
        _point = int.parse(json['point']),
        _email = json['email'];

  int get point => _point;

  set point(int value) {
    _point = value;
  }

  int get buyCount => _buyCount;

  set buyCount(int value) {
    _buyCount = value;
  }

  String? get rDate => _rDate;

  set rDate(String? value) {
    _rDate = value;
  }

  String? get nickName => _nickName;

  set nickName(String? value) {
    _nickName = value;
  }

  String? get studentId => _studentId;

  set studentId(String? value) {
    _studentId = value;
  }

  int get identity => _identity;

  set identity(int value) {
    _identity = value;
  }

  String? get name => _name;

  set name(String? value) {
    _name = value;
  }

  String? get token => _token;

  set token(String? value) {
    _token = value;
  }

  String? get uid => _uid;

  set uid(String? value) {
    _uid = value;
  }

  bool get isAdmin => _isAdmin;

  set isAdmin(bool value) {
    _isAdmin = value;
  }

  String? get adminKey => _adminKey;

  set adminKey(String? value) {
    _adminKey = value;
  }

  String? get email => _email;

  set email(String? value) {
    _email = value;
  }
}
