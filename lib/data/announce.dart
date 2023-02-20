class Announce {
  int announceID;
  String? writer;
  String? title;
  String? content;
  String? writeDate;
  int view;
  String? file;

  Announce(this.announceID, this.writer, this.title, this.content,
      this.writeDate, this.view, this.file);

  Announce.fromJson(Map<String, dynamic> json)
      : announceID = int.parse(json['anID']),
        writer = json['writer'],
        title = json['title'],
        content = json['content'],
        writeDate = json['writeDate'],
        view = int.parse(json['view']),
        file = json['file'];

}
