// To parse this JSON data, do
//
//     final group = groupFromJson(jsonString);

import 'dart:convert';

import 'package:smart_counter_app/app/models/counter_model.dart';

Group groupFromJson(String str) => Group.fromJson(json.decode(str));
List<Group> listGroupFromJson(String str) =>
    List<Group>.from(json.decode(str).map((x) => Group.fromJson(x)));
String groupToJson(Group data) => json.encode(data.toJson());
String groupToJson2(Group data) => json.encode(data.toJson2());

class Group {
  int? id;
  String name;
  String backgroundColor;
  String textColor;
  int sortOrder;
  List<Counter>? counters = [];
  int? countersCount;
  bool viewInGrid;
  int? gridCount;

  Group({
    this.id,
    required this.name,
    required this.backgroundColor,
    required this.textColor,
    required this.sortOrder,
    required this.viewInGrid,
    this.gridCount,
    this.counters,
    this.countersCount,
  });

  factory Group.fromJson(Map<String, dynamic> json) => Group(
        id: json["id"],
        name: json["name"],
        backgroundColor: json["background_color"],
        textColor: json["text_color"],
        sortOrder: json["sort_order"],
        counters: json["counters"] == null
            ? []
            : List<Counter>.from(
                json["counters"].map((x) => Counter.fromJson(x))),
        countersCount: json["counters_count"],
        viewInGrid: json["view_in_grid"] == 1 ? true : false,
        gridCount: json["grid_count"],
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != null) data["id"] = id;
    data["name"] = name;
    data["background_color"] = backgroundColor;
    data["text_color"] = textColor;
    data["sort_order"] = sortOrder;
    data["view_in_grid"] = viewInGrid == true ? 1 : 0;
    data["grid_count"] = gridCount;
    return data;
  }

  Map<String, dynamic> toJson2() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != null) data["id"] = id;
    data["name"] = name;
    data["background_color"] = backgroundColor;
    data["text_color"] = textColor;
    data["sort_order"] = sortOrder;
    data["view_in_grid"] = viewInGrid == true ? 1 : 0;
    data["grid_count"] = gridCount;
    if (counters != null) {
      data["counters"] = counters!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  Group copyWith({
    int? id,
    String? name,
    String? backgroundColor,
    String? textColor,
    int? sortOrder,
    List<Counter>? counters,
    int? countersCount,
    bool? viewInGrid,
    int? gridCount,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      sortOrder: sortOrder ?? this.sortOrder,
      counters: counters ?? this.counters,
      countersCount: countersCount ?? this.countersCount,
      viewInGrid: viewInGrid ?? this.viewInGrid,
      gridCount: gridCount ?? this.gridCount,
    );
  }
}
