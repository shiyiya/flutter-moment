import 'package:flutter/cupertino.dart';

class Event {
  int id;
  int authorId;
  String icon;
  String name;
  int created;
  String description;
  int status;

  Event(
      {this.id,
      this.authorId = 0,
      this.icon,
      @required this.name,
      this.created = 0,
      this.description = '',
      this.status = 1});

  Event.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    authorId = json['authorId'];
    icon = json['icon'];
    name = json['name'];
    created = json['created'];
    description = json['description'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['authorId'] = this.authorId;
    data['icon'] = this.icon;
    data['name'] = this.name;
    data['created'] = this.created;
    data['description'] = this.description;
    data['status'] = this.status;
    return data;
  }
}
