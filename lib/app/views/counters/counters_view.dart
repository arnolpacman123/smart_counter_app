import 'package:flutter/material.dart';

import 'package:smart_counter_app/app/views/counters/my_app_bar.dart';
import 'package:smart_counter_app/app/views/counters/my_body.dart';
import 'package:smart_counter_app/app/views/counters/my_floating_action_button.dart';
import 'package:smart_counter_app/app/views/groups/my_drawer.dart';

class CountersView extends StatelessWidget {
  const CountersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      drawer: const MyDrawer(),
      body: const MyBody(),
      floatingActionButton: MyFloatingActionButton(),
    );
  }
}
