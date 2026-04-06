// lib/app/routes/app_pages.dart
import 'package:get/get.dart';

import '../modules/dashboard/bindings/dashboard_binding.dart'; // <-- Import baru
import '../modules/dashboard/views/dashboard_view.dart'; // <-- Import baru
import '../modules/history/bindings/history_binding.dart';
import '../modules/history/views/history_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  // Set halaman awal jadi DASHBOARD
  static const INITIAL = Routes.DASHBOARD;

  static final routes = [
    GetPage(name: _Paths.HOME, page: () => HomeView(), binding: HomeBinding()),
    GetPage(
      name: _Paths.HISTORY,
      page: () => HistoryView(),
      binding: HistoryBinding(),
    ),
    GetPage(
      name: _Paths.DASHBOARD,
      page: () => DashboardView(),
      binding: DashboardBinding(), // <-- Binding utama
    ),
  ];
}
