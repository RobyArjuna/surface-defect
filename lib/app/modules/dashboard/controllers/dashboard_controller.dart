// lib/app/modules/dashboard/dashboard_controller.dart
import 'package:get/get.dart';

class DashboardController extends GetxController {
  // .obs membuat variabel ini reaktif
  var tabIndex = 0.obs;

  // Fungsi untuk ganti tab
  void changeTabIndex(int index) {
    tabIndex.value = index;
  }
}
