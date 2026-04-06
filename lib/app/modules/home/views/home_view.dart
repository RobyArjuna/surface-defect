import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:surface_defect/app/modules/home/controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Deteksi Cacat Manufaktur'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Obx(
              () => Column(
                // Dibungkus Obx untuk update UI
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Preview Foto',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 10),

                  // Area Preview Foto
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: controller.image.value == null
                        ? Center(
                            child: Icon(
                              Icons.image,
                              size: 100,
                              color: Colors.grey[400],
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(11.0),
                            child: Image.file(
                              controller.image.value!,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                  SizedBox(height: 20),

                  // Tombol Upload
                  ElevatedButton.icon(
                    icon: Icon(Icons.photo_library),
                    label: Text('Upload Foto (Galeri)'),
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.pickImage(ImageSource.gallery),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),

                  // Tombol Buka Kamera
                  ElevatedButton.icon(
                    icon: Icon(Icons.camera_alt),
                    label: Text('Buka Kamera'),
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.pickImage(ImageSource.camera),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Tombol Submit
                  ElevatedButton.icon(
                    icon: Icon(Icons.cloud_upload),
                    label: Text('Submit'),
                    onPressed:
                        (controller.image.value == null ||
                            controller.isLoading.value)
                        ? null
                        : controller.submitImage,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 30),

                  // Tampilan Status/Hasil
                  if (controller.isLoading.value)
                    Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 15),
                        Text(
                          controller.status.value,
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    )
                  else
                    Text(
                      controller.status.value,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),

                  // --- KARTU HASIL ---
                  if (controller.result.value != null &&
                      !controller.isLoading.value)
                    Card(
                      elevation: 4,
                      margin: EdgeInsets.only(top: 20),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Hasil Klasifikasi',
                              style: Theme.of(context).textTheme.titleLarge,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 15),
                            Text(
                              controller.result.value!['predicted_class'],
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 5),
                            Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Confidence: ${controller.result.value!['confidence_percent']}',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.green[900],
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            // --- 👇 UI BEST PRACTICE (Sorting + Progress Bar) 👇 ---
                            SizedBox(height: 20),
                            Divider(),
                            Text(
                              'Analisis Detail:',
                              style: Theme.of(context).textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 10),

                            Builder(
                              builder: (context) {
                                // 1. Ambil data map dari Controller
                                var rawMap =
                                    controller
                                            .result
                                            .value!['all_probabilities']
                                        as Map<String, dynamic>;

                                // 2. Ubah ke List agar bisa di-SORTING (Besar -> Kecil)
                                // Ini kunci agar hasil prediksi tertinggi ada di atas
                                var sortedEntries = rawMap.entries.toList()
                                  ..sort(
                                    (a, b) => (b.value as double).compareTo(
                                      a.value as double,
                                    ),
                                  );

                                return Column(
                                  children: sortedEntries.map((entry) {
                                    double value =
                                        entry.value
                                            as double; // Nilai 0.0 - 1.0 dari Python
                                    double percent =
                                        value * 100; // Ubah ke persen visual

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6.0,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Baris Label & Persentase Text
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                entry.key, // Nama Kelas
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: value > 0.5
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                ),
                                              ),
                                              Text(
                                                '${percent.toStringAsFixed(2)}%', // Format String di sini
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: value > 0.5
                                                      ? Colors.blue
                                                      : Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 4),

                                          // Visualisasi Progress Bar (Butuh nilai 0.0 - 1.0)
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            child: LinearProgressIndicator(
                                              value:
                                                  value, // Menggunakan raw value float dari backend!
                                              backgroundColor: Colors.grey[200],
                                              color: value > 0.5
                                                  ? Colors.blue
                                                  : Colors.blue[200],
                                              minHeight: 8,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                            // --- 👆 AKHIR BAGIAN BARU 👆 ---
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
