// lib/app/modules/history/history_view.dart
import 'dart:io'; // Untuk Image.file
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:surface_defect/app/modules/history/controllers/history_controller.dart';

class HistoryView extends GetView<HistoryController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('History Klasifikasi'), centerTitle: true),
      // Bungkus dengan Obx agar list-nya update otomatis
      body: Obx(() {
        if (controller.historyItems.isEmpty) {
          return Center(child: Text('Belum ada riwayat deteksi.'));
        }

        // Tampilkan list riwayat
        return ListView.builder(
          itemCount: controller.historyItems.length,
          itemBuilder: (context, index) {
            final item = controller.historyItems[index];
            final imagePath = item['imagePath'] as String?;
            final file = (imagePath != null) ? File(imagePath) : null;

            return Card(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                // Tampilkan gambar (jika path-nya ada)
                leading:
                    (file != null &&
                        file.existsSync()) // Cek jika file masih ada
                    ? Image.file(file, width: 50, height: 50, fit: BoxFit.cover)
                    : Icon(Icons.image_not_supported, size: 50),
                // Tampilkan kelas prediksi
                title: Text(
                  item['class'] ?? 'N/A',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                // Tampilkan skor confidence
                subtitle: Text('Confidence: ${item['confidence'] ?? 'N/A'}'),
              ),
            );
          },
        );
      }),
    );
  }
}
