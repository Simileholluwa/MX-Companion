import 'package:get/get.dart';
import 'package:mx_companion_v1/config/local_storage.dart';
import 'package:mx_companion_v1/controllers/auth_controller.dart';

class InitialBinding implements Bindings {
  @override
  Future<void> dependencies() async {
    Get.put(AuthController(), permanent: true);

    await Get.putAsync<StorageService>(() => StorageService().init());
  }
}