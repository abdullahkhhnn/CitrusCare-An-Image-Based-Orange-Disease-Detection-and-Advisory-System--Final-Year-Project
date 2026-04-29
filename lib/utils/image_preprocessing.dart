import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImagePreprocessing {
  static const int inputSize = 224;
  
  /// Preprocesses image for TensorFlow Lite model
  /// Returns Float32List in shape [1, 224, 224, 3]
  static Future<Float32List> preprocessImage(File imageFile) async {
    try {
      // Read image file
      final bytes = await imageFile.readAsBytes();
      
      // Decode image
      img.Image? image = img.decodeImage(bytes);
      
      if (image == null) {
        throw Exception('Failed to decode image');
      }
      
      // Resize to 224x224
      img.Image resizedImage = img.copyResize(
        image,
        width: inputSize,
        height: inputSize,
        interpolation: img.Interpolation.linear,
      );
      
      // Convert to Float32List and normalize
      return _imageToFloat32List(resizedImage);
    } catch (e) {
      throw Exception('Image preprocessing failed: $e');
    }
  }

  /// Converts image to normalized Float32List
  static Float32List _imageToFloat32List(img.Image image) {
    // Create buffer for [224, 224, 3] = 150,528 values
    final convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    final buffer = Float32List.view(convertedBytes.buffer);
    
    int pixelIndex = 0;
    
    // Iterate through each pixel
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = image.getPixel(x, y);
        
        // Extract RGB values and normalize to [0, 1]
        buffer[pixelIndex++] = pixel.r / 255.0;
        buffer[pixelIndex++] = pixel.g / 255.0;
        buffer[pixelIndex++] = pixel.b / 255.0;
      }
    }
    
    return convertedBytes;
  }

  /// Get image dimensions
  static Future<Map<String, int>> getImageDimensions(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    
    if (image == null) {
      return {'width': 0, 'height': 0};
    }
    
    return {
      'width': image.width,
      'height': image.height,
    };
  }

  /// Validate image file
  static Future<bool> validateImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);
      return image != null;
    } catch (e) {
      return false;
    }
  }
}