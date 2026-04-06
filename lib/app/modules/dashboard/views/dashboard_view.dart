// lib/app/modules/dashboard/dashboard_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:surface_defect/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:surface_defect/app/modules/history/views/history_view.dart';
import 'package:surface_defect/app/modules/home/views/home_view.dart';

class DashboardView extends GetView<DashboardController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Kita gunakan Obx untuk memantau perubahan tabIndex
      body: Obx(
        () => IndexedStack(
          index: controller.tabIndex.value, // Index halaman
          children: [
            HomeView(), // Halaman 0
            HistoryView(), // Halaman 1
          ],
        ),
      ),

      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.tabIndex.value, // Index item
          onTap: controller.changeTabIndex, // Panggil fungsi controller
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
          ],
        ),
      ),
    );
  }
}
