import 'dart:io';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:surface_defect/app/modules/history/controllers/history_controller.dart';
import 'package:surface_defect/app/services/onnx_classifier_service.dart';

class HomeController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final box = GetStorage();
  final OnnxClassifierService classifier = Get.find<OnnxClassifierService>();

  var image = Rx<File?>(null);
  var status = 'Belum ada foto dipilih'.obs;
  var result = Rx<Map<String, dynamic>?>(null);
  var isLoading = false.obs;

  void pickImage(ImageSource source) async {
    isLoading.value = true;
    status.value = 'Mengambil gambar...';
    result.value = null;

    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        image.value = File(pickedFile.path);
        status.value = 'Gambar dipilih. Klik Submit.';
      } else {
        status.value = 'Pengambilan gambar dibatalkan.';
      }
    } catch (e) {
      status.value = 'Error mengambil gambar: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void submitImage() async {
    if (image.value == null) {
      status.value = 'Pilih gambar terlebih dahulu!';
      return;
    }

    isLoading.value = true;
    status.value = 'Menganalisis gambar di device...';
    result.value = null;

    try {
      final prediction = await classifier.predict(image.value!);
      result.value = prediction;
      status.value = 'Klasifikasi Selesai!';

      try {
        final newItem = {
          'imagePath': image.value!.path,
          'class': prediction['predicted_class'],
          'confidence': prediction['confidence_percent'],
          'top_predictions': prediction['top_predictions'],
        };

        List<dynamic> historyList = box.read<List<dynamic>>('history') ?? [];
        historyList.insert(0, newItem);
        await box.write('history', historyList);

        Get.find<HistoryController>().loadHistory();
      } catch (e) {
        print("Error saat menyimpan history: $e");
      }
    } catch (e) {
      status.value = 'Error inferensi lokal: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
