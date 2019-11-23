class Moment {
  int cid;
  String title;
  String text;
  int created;
  int modified;
  String event;
  int face;
  int weather;
  String alum;
  int authorId;
  String status;
  String password;
  String location;
  int allowComment;
  int commentsNum;

  Moment(
      {this.cid,
      this.title = '',
      this.text = '',
      this.created = 0,
      this.modified = 0,
      this.event = '',
      this.face = 2,
      this.weather = 3,
      this.alum = '',
      this.authorId = 0,
      this.status = 'publish',
      this.password = '',
      this.location = '',
      this.allowComment = 0,
      this.commentsNum = 0});

  Moment.fromJson(Map<String, dynamic> json) {
    cid = json['cid'];
    title = json['title'];
    text = json['text'];
    created = json['created'];
    modified = json['modified'];
    event = json['event'];
    face = json['face'];
    weather = json['weather'];
    alum = json['alum'];
    authorId = json['authorId'];
    status = json['status'];
    password = json['password'];
    location = json['location'];
    allowComment = json['allowComment'];
    commentsNum = json['commentsNum'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cid'] = this.cid;
    data['title'] = this.title;
    data['text'] = this.text;
    data['created'] = this.created;
    data['modified'] = this.modified;
    data['event'] = this.event;
    data['face'] = this.face;
    data['weather'] = this.weather;
    data['alum'] = this.alum;
    data['authorId'] = this.authorId;
    data['status'] = this.status;
    data['password'] = this.password;
    data['location'] = this.location;
    data['allowComment'] = this.allowComment;
    data['commentsNum'] = this.commentsNum;
    return data;
  }
}

class MomentInfo {
  int count;
  int wordCount;
  int imgCount;

  MomentInfo({this.count = 0, this.wordCount = 0, this.imgCount = 0});

  MomentInfo.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    wordCount = json['wordCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['count'] = this.count;
    data['wordCount'] = this.wordCount;
    return data;
  }
}
