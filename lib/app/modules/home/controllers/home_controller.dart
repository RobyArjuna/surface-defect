// lib/app/modules/home/home_controller.dart
import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:get_storage/get_storage.dart';
import 'package:surface_defect/app/modules/history/controllers/history_controller.dart';

const String FLASK_API_URL = 'http://192.168.1.14:5000/predict';

class HomeController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final box = GetStorage();

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
    status.value = 'Mengirim & Menganalisis Gambar...';
    result.value = null;

    try {
      var uri = Uri.parse(FLASK_API_URL);
      var request = http.MultipartRequest('POST', uri)
        ..files.add(
          await http.MultipartFile.fromPath(
            'image',
            image.value!.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var decodedJson = jsonDecode(responseBody);
        result.value = decodedJson;
        status.value = 'Klasifikasi Selesai!';

        try {
          final newItem = {
            'imagePath': image.value!.path, // Simpan path gambar
            'class': decodedJson['predicted_class'],
            'confidence': decodedJson['confidence_percent'],
          };

          List<dynamic> historyList = box.read<List<dynamic>>('history') ?? [];

          historyList.insert(0, newItem);
          await box.write('history', historyList);

          Get.find<HistoryController>().loadHistory();
        } catch (e) {
          print("Error saat menyimpan history: $e");
        }
      } else {
        status.value =
            'Error Server: ${response.statusCode}\nRespons: $responseBody';
      }
    } catch (e) {
      status.value =
          'Error Koneksi: $e\nPastikan server Flask berjalan & IP sudah benar.';
    } finally {
      isLoading.value = false;
    }
  }
}
