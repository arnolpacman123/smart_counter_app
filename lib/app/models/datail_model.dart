// To parse this JSON data, do
//
//     final detail = detailFromJson(jsonString);

import 'dart:convert';

List<Detail> detailFromJson(String str) =>
    List<Detail>.from(json.decode(str).map((x) => Detail.fromJson(x)));

String detailToJson(List<Detail> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Detail {
  final int? id;
  final String name;
  final DateTime date;
  final String action;
  final int value;
  final int groupId;

  Detail({
    this.id,
    required this.name,
    required this.date,
    required this.action,
    required this.value,
    required this.groupId,
  });

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
        id: json["id"],
        name: json["name"],
        date: DateTime.parse(json["date"]),
        action: json["action"],
        value: json["value"],
        groupId: json["group_id"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "date": date.toIso8601String(),
        "action": action,
        "value": value,
        "group_id": groupId,
      };

  Detail copyWith({
    int? id,
    String? name,
    DateTime? date,
    String? action,
    int? value,
    int? groupId,
  }) =>
      Detail(
        id: id ?? this.id,
        name: name ?? this.name,
        date: date ?? this.date,
        action: action ?? this.action,
        value: value ?? this.value,
        groupId: groupId ?? this.groupId,
      );
}
