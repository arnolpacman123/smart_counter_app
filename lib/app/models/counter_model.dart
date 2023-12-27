// To parse this JSON data, do
//
//     final counter = counterFromJson(jsonString);

import 'dart:convert';

Counter counterFromJson(String str) => Counter.fromJson(json.decode(str));
List<Counter> listCounterFromJson(String str) => List<Counter>.from(
      json.decode(str).map((x) => Counter.fromJson(x)),
    );
String counterToJson(Counter data) => json.encode(data.toJson());

class Counter {
  int? id;
  String name;
  String backgroundColor;
  String textColor;
  int value;
  int reset;
  int incremental;
  int decremental;
  int sortOrder;
  int? groupId;

  Counter({
    this.id,
    required this.name,
    required this.backgroundColor,
    required this.textColor,
    required this.value,
    required this.reset,
    required this.incremental,
    required this.decremental,
    required this.sortOrder,
    this.groupId,
  });

  factory Counter.fromJson(Map<String, dynamic> json) => Counter(
        id: json["id"],
        name: json["name"],
        backgroundColor: json["background_color"],
        textColor: json["text_color"],
        value: json["value"],
        reset: json["reset"],
        incremental: json["incremental"],
        decremental: json["decremental"],
        sortOrder: json["sort_order"],
        groupId: json["group_id"],
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != null) data["id"] = id;
    data["name"] = name;
    data["background_color"] = backgroundColor;
    data["text_color"] = textColor;
    data["value"] = value;
    data["reset"] = reset;
    data["incremental"] = incremental;
    data["decremental"] = decremental;
    data["sort_order"] = sortOrder;
    if (groupId != null) data["group_id"] = groupId;
    return data;
  }

  Counter copyWith({
    int? id,
    String? name,
    String? backgroundColor,
    String? textColor,
    int? value,
    int? reset,
    int? incremental,
    int? decremental,
    int? sortOrder,
    int? groupId,
  }) {
    return Counter(
      id: id,
      name: name ?? this.name,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      value: value ?? this.value,
      reset: reset ?? this.reset,
      incremental: incremental ?? this.incremental,
      decremental: decremental ?? this.decremental,
      sortOrder: sortOrder ?? this.sortOrder,
      groupId: groupId ?? this.groupId,
    );
  }
}
