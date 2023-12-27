import 'package:flutter/material.dart';
import 'package:smart_counter_app/app/views/counters/counters_view.dart';
import 'package:smart_counter_app/app/views/groups/groups_view.dart';

abstract class Routes {
  static const String groups = '/groups';
  static const String counters = '/counters';

  static final routes = <String, WidgetBuilder>{
    Routes.groups: (context) => const GroupsView(),
    Routes.counters: (context) => const CountersView(),
  };
}
