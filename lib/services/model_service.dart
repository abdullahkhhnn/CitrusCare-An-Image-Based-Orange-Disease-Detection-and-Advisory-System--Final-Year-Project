import 'dart:typed_data';
import 'package:tflite_v2/tflite_v2.dart';
import '../constants/labels.dart';

class ModelService {
  static bool _isModelLoaded = false;

  // Minimum confidence threshold
  // Predictions below this are rejected as invalid
  static const double _confidenceThreshold = 0.55; // 70%

  /// Load the TFLite model
  static Future<void> loadModel() async {
    if (_isModelLoaded) {
      print('Model already loaded');
      return;
    }

    try {
      String? result = await Tflite.loadModel(
        model: "assets/plant_disease_model.tflite",
        labels: "assets/labels.txt",
        numThreads: 1,
        isAsset: true,
        useGpuDelegate: false,
      );

      _isModelLoaded = true;
      print('✅ Model loaded successfully: $result');
    } catch (e) {
      print('❌ Error loading model: $e');
      throw Exception('Failed to load TFLite model: $e');
    }
  }

  /// Run inference on image file path
  static Future<Map<String, dynamic>> predictFromImagePath(String imagePath) async {
    if (!_isModelLoaded) {
      await loadModel();
    }

    try {
      print('📸 Analyzing image: $imagePath');
      print('🔧 Preprocessing: imageMean=127.5, imageStd=127.5');
      
      var recognitions = await Tflite.runModelOnImage(
        path: imagePath,
        imageMean: 127.5,
        imageStd: 127.5,
        numResults: 3,
        threshold: 0.0,
        asynch: true,
      );

      print('🔍 Raw model output: $recognitions');

      if (recognitions == null || recognitions.isEmpty) {
        throw Exception('No predictions returned');
      }

      // recognitions is sorted by confidence
      // Format: [{index: 2, confidence: 0.93, label: "2 LeafMinor"}, ...]
      
      // Create probabilities array in correct order [Aphids, Healthy, LeafMinor]
      List<double> probabilities = [0.0, 0.0, 0.0];
      
      for (var result in recognitions) {
        int index = result['index'];
        double confidence = result['confidence'] ?? 0.0;
        probabilities[index] = confidence;
        print('  Class $index: ${(confidence * 100).toStringAsFixed(1)}%');
      }
      
      print('📊 Final probabilities [Aphids, Healthy, LeafMinor]: $probabilities');
      
      // Get best prediction (first in sorted list)
      var bestPrediction = recognitions.first;
      int classIndex = bestPrediction['index'];
      double confidence = bestPrediction['confidence'];
      String disease = DiseaseLabels.getLabel(classIndex);

      print('📊 Best prediction: $disease (${(confidence * 100).toStringAsFixed(1)}%)');

      // Check confidence threshold
      if (confidence < _confidenceThreshold) {
        print('❌ Confidence too low: ${(confidence * 100).toStringAsFixed(1)}% < ${(_confidenceThreshold * 100).toStringAsFixed(0)}%');
        
        return {
          'disease': 'Unknown',
          'confidence': confidence,
          'probabilities': probabilities,
          'classIndex': -1,
          'isValid': false,
          'errorMessage': 'Image does not appear to be a citrus leaf.\nPlease take a clear photo of a citrus leaf.',
        };
      }

      print('✅ Valid prediction: $disease (${(confidence * 100).toStringAsFixed(1)}%)');

      return {
        'disease': disease,
        'confidence': confidence,
        'probabilities': probabilities,
        'classIndex': classIndex,
        'isValid': true,
        'errorMessage': '',
      };
    } catch (e) {
      print('❌ Prediction error: $e');
      throw Exception('Prediction failed: $e');
    }
  }

  /// Run inference on preprocessed image (for compatibility)
  static Future<Map<String, dynamic>> predict(Float32List input) async {
    // This package doesn't use Float32List directly
    // Fallback to mock for this signature
    throw UnimplementedError('Use predictFromImagePath instead');
  }

  /// Get all class probabilities with labels
  static Map<String, double> getProbabilitiesWithLabels(List<double> probabilities) {
    Map<String, double> result = {};

    for (int i = 0; i < probabilities.length; i++) {
      String label = DiseaseLabels.getLabel(i);
      result[label] = probabilities[i];
    }

    return result;
  }

  /// Dispose
  static Future<void> dispose() async {
    await Tflite.close();
    _isModelLoaded = false;
    print('Model disposed');
  }
}