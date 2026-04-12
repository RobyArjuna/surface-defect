// lib/main.dart
import 'package:flutter/widgets.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app/routes/app_pages.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/services/onnx_classifier_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await GetStorage.init();

  final classifier = OnnxClassifierService();
  await classifier.init();
  Get.put<OnnxClassifierService>(classifier, permanent: true);

  runApp(
    GetMaterialApp(
      title: "Aplikasi Deteksi Cacat",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
