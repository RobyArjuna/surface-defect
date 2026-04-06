// lib/app/modules/history/history_controller.dart
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class HistoryController extends GetxController {
  final box = GetStorage(); // Buka box GetStorage

  // Daftar riwayat (reaktif)
  var historyItems = RxList<Map<String, dynamic>>([]);

  @override
  void onInit() {
    super.onInit();
    loadHistory(); // Panggil fungsi load saat controller pertama kali dibuat
  }

  // Fungsi untuk memuat data dari GetStorage
  void loadHistory() {
    List<dynamic> historyList = box.read<List<dynamic>>('history') ?? [];
    historyItems.value = List<Map<String, dynamic>>.from(historyList);
    print("History loaded: ${historyItems.length} items");
  }
}
