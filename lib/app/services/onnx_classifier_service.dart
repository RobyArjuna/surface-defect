import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:image/image.dart' as img;

class OnnxClassifierService {
  final OnnxRuntime _ort = OnnxRuntime();

  OrtSession? _session;
  List<String> _labels = [];

  Future<void> init() async {
    _session = await _ort.createSessionFromAsset(
      'assets/models/mobilevit_xs_surface_defect.onnx',
    );

    final labelsRaw = await rootBundle.loadString('assets/models/labels.txt');
    _labels = labelsRaw
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<Map<String, dynamic>> predict(File imageFile) async {
    if (_session == null) {
      throw Exception('ONNX session belum diinisialisasi.');
    }

    final inputTensor = await _preprocessImage(imageFile);

    final inputName = _session!.inputNames[0];
    final outputName = _session!.outputNames[0];

    final inputs = {inputName: inputTensor};

    final outputs = await _session!.run(inputs);

    final outputTensor = outputs[outputName];
    if (outputTensor == null) {
      throw Exception('Output tensor tidak ditemukan.');
    }

    final rawOutput = await outputTensor.asList();
    final logits = _flattenToDoubleList(rawOutput);

    final probabilities = _softmax(logits);

    final indexed = List.generate(probabilities.length, (i) {
      return {
        'index': i,
        'class_name': _labels[i],
        'confidence_score': probabilities[i],
        'confidence_percent': '${(probabilities[i] * 100).toStringAsFixed(2)}%',
      };
    });

    indexed.sort(
      (a, b) => (b['confidence_score'] as double).compareTo(
        a['confidence_score'] as double,
      ),
    );

    final predicted = indexed.first;
    final topPredictions = indexed.take(3).toList();

    final allProbabilities = {
      for (final item in indexed)
        item['class_name'] as String: item['confidence_score'] as double,
    };

    // dispose tensors
    inputTensor.dispose();
    for (final tensor in outputs.values) {
      tensor.dispose();
    }

    return {
      'predicted_class': predicted['class_name'],
      'confidence_score': predicted['confidence_score'],
      'confidence_percent': predicted['confidence_percent'],
      'top_predictions': topPredictions,
      'all_probabilities': allProbabilities,
    };
  }

  Future<OrtValue> _preprocessImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final decoded = img.decodeImage(bytes);

    if (decoded == null) {
      throw Exception('Gagal membaca gambar.');
    }

    final resized = img.copyResize(decoded, width: 224, height: 224);

    const mean = [0.485, 0.456, 0.406];
    const std = [0.229, 0.224, 0.225];

    final input = Float32List(1 * 3 * 224 * 224);

    int rIndex = 0;
    int gIndex = 224 * 224;
    int bIndex = 2 * 224 * 224;

    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final pixel = resized.getPixel(x, y);

        final r = pixel.r / 255.0;
        final g = pixel.g / 255.0;
        final b = pixel.b / 255.0;

        input[rIndex++] = ((r - mean[0]) / std[0]).toDouble();
        input[gIndex++] = ((g - mean[1]) / std[1]).toDouble();
        input[bIndex++] = ((b - mean[2]) / std[2]).toDouble();
      }
    }

    return OrtValue.fromList(input, [1, 3, 224, 224]);
  }

  List<double> _softmax(List<double> logits) {
    final maxLogit = logits.reduce((a, b) => a > b ? a : b);
    final exps = logits.map((x) => math.exp(x - maxLogit)).toList();
    final sumExp = exps.reduce((a, b) => a + b);
    return exps.map((e) => e / sumExp).toList();
  }

  List<double> _flattenToDoubleList(dynamic value) {
    if (value is List) {
      if (value.isNotEmpty && value.first is List) {
        return (value.first as List).map((e) => (e as num).toDouble()).toList();
      }
      return value.map((e) => (e as num).toDouble()).toList();
    }
    throw Exception('Format output model tidak dikenali.');
  }

  Future<void> dispose() async {
    await _session?.close();
  }
}
