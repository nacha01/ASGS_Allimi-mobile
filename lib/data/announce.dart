class Announce {
  int _announceID;
  String? _writer;
  String? _title;
  String? _content;
  String? _writeDate;
  int _view;
  String? _file;

  Announce(this._announceID, this._writer, this._title, this._content,
      this._writeDate, this._view, this._file);

  Announce.fromJson(Map<String, dynamic> json)
      : _announceID = int.parse(json['anID']),
        _writer = json['writer'],
        _title = json['title'],
        _content = json['content'],
        _writeDate = json['writeDate'],
        _view = int.parse(json['view']),
        _file = json['file'];

  int get announceID => _announceID;

  set announceID(int value) {
    _announceID = value;
  }

  String? get writer => _writer;

  String? get file => _file;

  set file(String? value) {
    _file = value;
  }

  int get view => _view;

  set view(int value) {
    _view = value;
  }

  String? get writeDate => _writeDate;

  set writeDate(String? value) {
    _writeDate = value;
  }

  String? get content => _content;

  set content(String? value) {
    _content = value;
  }

  String? get title => _title;

  set title(String? value) {
    _title = value;
  }

  set writer(String? value) {
    _writer = value;
  }
}
