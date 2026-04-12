import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:surface_defect/app/modules/home/controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deteksi Cacat Manufaktur'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Obx(() {
              final result = controller.result.value;
              final isLoading = controller.isLoading.value;
              final image = controller.image.value;
              final status = controller.status.value;

              final topPredictions =
                  (result?['top_predictions'] as List<dynamic>?) ?? [];

              final allProbabilities =
                  (result?['all_probabilities'] as Map<String, dynamic>?) ?? {};

              final sortedEntries = allProbabilities.entries.toList()
                ..sort(
                  (a, b) => (b.value as num).toDouble().compareTo(
                    (a.value as num).toDouble(),
                  ),
                );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Preview Foto',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: image == null
                        ? Center(
                            child: Icon(
                              Icons.image,
                              size: 100,
                              color: Colors.grey[400],
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: Image.file(image, fit: BoxFit.cover),
                          ),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Upload Foto (Galeri)'),
                    onPressed: isLoading
                        ? null
                        : () => controller.pickImage(ImageSource.gallery),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),

                  ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Buka Kamera'),
                    onPressed: isLoading
                        ? null
                        : () => controller.pickImage(ImageSource.camera),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    icon: const Icon(Icons.analytics),
                    label: const Text('Submit'),
                    onPressed: (image == null || isLoading)
                        ? null
                        : controller.submitImage,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),

                  if (isLoading)
                    Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 15),
                        Text(
                          status,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                  else
                    Text(
                      status,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),

                  if (result != null && !isLoading) ...[
                    const SizedBox(height: 20),
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Hasil Klasifikasi',
                              style: Theme.of(context).textTheme.titleLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),

                            Text(
                              result['predicted_class']?.toString() ?? '-',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Confidence: ${result['confidence_percent'] ?? '-'}',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.green[900],
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            if (topPredictions.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              const Divider(),
                              Text(
                                'Top 3 Kemungkinan',
                                style: Theme.of(context).textTheme.titleMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),

                              ...topPredictions.asMap().entries.map((entry) {
                                final index = entry.key;
                                final item =
                                    entry.value as Map<String, dynamic>;

                                final className =
                                    item['class_name']?.toString() ?? '-';
                                final confidencePercent =
                                    item['confidence_percent']?.toString() ??
                                    '-';
                                final confidenceScore =
                                    ((item['confidence_score'] as num?) ?? 0)
                                        .toDouble();

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: index == 0
                                        ? Colors.blue.withOpacity(0.08)
                                        : Colors.grey.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: index == 0
                                          ? Colors.blue.withOpacity(0.3)
                                          : Colors.grey.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 14,
                                            backgroundColor: index == 0
                                                ? Colors.blue
                                                : Colors.grey,
                                            child: Text(
                                              '${index + 1}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              className,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            confidencePercent,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: index == 0
                                                  ? Colors.blue
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: LinearProgressIndicator(
                                          value: confidenceScore,
                                          minHeight: 8,
                                          backgroundColor: Colors.grey[200],
                                          color: index == 0
                                              ? Colors.blue
                                              : Colors.blue[300],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],

                            if (sortedEntries.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              const Divider(),
                              Text(
                                'Analisis Detail',
                                style: Theme.of(context).textTheme.titleMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),

                              ...sortedEntries.map((entry) {
                                final value = (entry.value as num).toDouble();
                                final percent = value * 100;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              entry.key,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight:
                                                    value ==
                                                        sortedEntries
                                                            .first
                                                            .value
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            '${percent.toStringAsFixed(2)}%',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  value ==
                                                      (sortedEntries.first.value
                                                              as num)
                                                          .toDouble()
                                                  ? Colors.blue
                                                  : Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: value,
                                          backgroundColor: Colors.grey[200],
                                          color:
                                              value ==
                                                  (sortedEntries.first.value
                                                          as num)
                                                      .toDouble()
                                              ? Colors.blue
                                              : Colors.blue[200],
                                          minHeight: 8,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
