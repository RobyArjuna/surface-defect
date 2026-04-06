// lib/app/modules/dashboard/dashboard_binding.dart
import 'package:get/get.dart';
import 'package:surface_defect/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:surface_defect/app/modules/history/controllers/history_controller.dart';
import 'package:surface_defect/app/modules/home/controllers/home_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
    // Kita pakai fenix: true agar controller-nya dibuat ulang saat dibutuhkan
    // tapi Get.put() juga oke agar state-nya tidak hilang.
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<HistoryController>(() => HistoryController(), fenix: true);
  }
}
