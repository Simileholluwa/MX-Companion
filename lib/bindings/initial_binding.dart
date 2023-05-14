import 'package:get/get.dart';
import 'package:mx_companion_v1/config/local_storage.dart';
import 'package:mx_companion_v1/controllers/auth_controller.dart';
import 'package:mx_companion_v1/controllers/connectivity.dart';

class InitialBinding implements Bindings {
  @override
  Future<void> dependencies() async {
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<InternetConnectivityController>(InternetConnectivityController());
    await Get.putAsync<StorageService>(() => StorageService().init());
  }
}