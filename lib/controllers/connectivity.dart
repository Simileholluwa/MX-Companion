import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';


class InternetConnectivityController extends GetxController {
  Connectivity connectivity = Connectivity();
  RxBool isConnected = false.obs;

  @override
  void onInit() {
    super.onInit();
    connectivity.onConnectivityChanged.listen((event) {
      updateInternetConnectivity(event);
    });
  }

  void updateInternetConnectivity(ConnectivityResult event) {
    switch (event) {
      case ConnectivityResult.none:
        isConnected.value = false;
        break;
      case ConnectivityResult.wifi:
        isConnected.value = true;
        break;
      case ConnectivityResult.mobile:
        isConnected.value = true;
        break;
      case ConnectivityResult.other:
        isConnected.value = false;
        break;
      case ConnectivityResult.bluetooth:
        isConnected.value = false;
        break;
      case ConnectivityResult.ethernet:
        isConnected.value = false;
        break;
      case ConnectivityResult.vpn:
        isConnected.value = false;
        break;
    }
  }
}
