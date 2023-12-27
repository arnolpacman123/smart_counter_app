import 'package:get/instance_manager.dart';
import 'package:smart_counter_app/app/controllers/groups_controller.dart';

class GlobalBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GroupsController>(
      () => GroupsController(),
      fenix: true,
    );
  }
}
