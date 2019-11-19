class Alum {
  int cid;
  String alum;

  Alum({this.cid, this.alum});

  Alum.fromJson(Map<String, dynamic> json) {
    cid = json['cid'];
    alum = json['alum'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cid'] = this.cid;
    data['alum'] = this.alum;
    return data;
  }
}
