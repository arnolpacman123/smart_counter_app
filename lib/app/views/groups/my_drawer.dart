import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'package:smart_counter_app/app/controllers/counters_controller.dart';
import 'package:smart_counter_app/app/controllers/groups_controller.dart';
import 'package:smart_counter_app/app/utils/functions/delete_dialog.dart';
import 'package:smart_counter_app/app/views/counters/counters_view.dart';
import 'package:smart_counter_app/app/views/groups/groups_view.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          ListTile(
            title: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: const Row(
                children: [
                  Icon(Icons.list),
                  SizedBox(
                    width: 16,
                  ),
                  Text('Todos los grupos'),
                ],
              ),
            ),
            onTap: () {
              Get.to(
                () => const GroupsView(),
                transition: Transition.fadeIn,
              );
            },
          ),
          const Divider(
            thickness: 0.7,
            height: 0,
          ),
          const Expanded(
            child: ListGroupDrawer(),
          )
        ],
      ),
    );
  }
}

class ListGroupDrawer extends StatefulWidget {
  const ListGroupDrawer({super.key});

  @override
  State<ListGroupDrawer> createState() => _ListGroupDrawerState();
}

class _ListGroupDrawerState extends State<ListGroupDrawer> {
  final controller = Get.find<GroupsController>();

  final expansionTileControllers = <ExpansionTileController>[];

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < controller.groups.length; i++) {
      expansionTileControllers.add(ExpansionTileController());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: controller.groups.length,
      physics: const ClampingScrollPhysics(),
      itemBuilder: (context, index) {
        final group = controller.groups[index];
        return Dismissible(
          key: Key(group.id.toString()),
          confirmDismiss: (direction) async {
            final result = await deleteDialog(
              title: 'Eliminar grupo',
              middleText: '¿Está seguro que desea eliminar este grupo?',
              onConfirm: () async {
                await controller.deleteGroup(group);
              },
              onCancel: () async {
                await controller.refreshGroups();
              },
            );
            if (result) {
              await controller.refreshGroups();
              if (controller.selectedGroupRx.value?.id == group.id) {
                controller.selectedGroupRx.value = null;
                Get.toNamed('/groups');
              }
            }
            return result;
          },
          child: MyExpansionTile(
            onTitleTap: () {
              controller.selectedGroup = group;
              Get.lazyPut<CountersController>(() => CountersController());
              Navigator.pop(context);
              Get.to(
                () => const CountersView(),
                transition: Transition.leftToRight,
              );
            },
            title: AutoSizeText(
              group.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            children: group.counters!.map((e) {
              return ListTile(
                onTap: () {},
                title: AutoSizeText(
                  e.name,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
      separatorBuilder: (context, index) {
        return const Divider(
          thickness: 0.7,
          height: 0,
        );
      },
    );
  }
}

class MyExpansionTile extends StatefulWidget {
  const MyExpansionTile({
    Key? key,
    required this.title,
    required this.children,
    this.onTitleTap,
  }) : super(key: key);
  final Widget title;
  final List<Widget> children;
  final void Function()? onTitleTap;

  @override
  State<StatefulWidget> createState() => _MyExpansionTileState();
}

class _MyExpansionTileState extends State<MyExpansionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconTurns;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _iconTurns = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    if (widget.onTitleTap != null) {
                      widget.onTitleTap!();
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 30),
                    height: 60,
                    alignment: Alignment.centerLeft,
                    child: widget.title,
                  ),
                ),
              ),
              InkWell(
                onTap: _handleTap,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 18),
                  height: 60,
                  alignment: Alignment.centerRight,
                  child: Center(
                    child: RotationTransition(
                      turns: _iconTurns,
                      child: const Icon(Icons.expand_more),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizeTransition(
          sizeFactor: CurvedAnimation(
            parent: _controller,
            curve: Curves.easeIn,
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: widget.children,
            ),
          ),
        ),
      ],
    );
  }
}
