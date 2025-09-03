import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'logger_service.dart';

class CloudinaryService {
  static const String cloudName = 'dougea9lu';
  static const String uploadPreset = 'gateease';
  static const String apiKey = '663992968785299';
  static const String apiSecret = 'iyUCr40GbVeIfbEVX16EBjKR1M8';

  static Future<String?> uploadImage(File imageFile, {String? folder}) async {
    try {
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', url);

      // Add the image file
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      // Add upload parameters
      request.fields['upload_preset'] = uploadPreset;
      request.fields['api_key'] = apiKey;

      if (folder != null) {
        request.fields['folder'] = folder;
      }

      // Add timestamp for signature
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      request.fields['timestamp'] = timestamp.toString();

      // Generate signature
      final signature = _generateSignature(timestamp, folder);
      request.fields['signature'] = signature;

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonData = json.decode(responseData);
        LoggerService.network('Image uploaded successfully to Cloudinary');
        return jsonData['secure_url'] as String;
      } else {
        LoggerService.error(
          'Cloudinary upload failed with status: ${response.statusCode}',
          'CLOUDINARY',
        );
        return null;
      }
    } catch (e) {
      LoggerService.error('Error uploading to Cloudinary', 'CLOUDINARY', e);
      return null;
    }
  }

  static Future<String?> uploadVideo(File videoFile, {String? folder}) async {
    try {
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/video/upload',
      );

      final request = http.MultipartRequest('POST', url);

      // Add the video file
      request.files.add(
        await http.MultipartFile.fromPath('file', videoFile.path),
      );

      // Add upload parameters
      request.fields['upload_preset'] = uploadPreset;
      request.fields['api_key'] = apiKey;
      request.fields['resource_type'] = 'video';

      if (folder != null) {
        request.fields['folder'] = folder;
      }

      // Add timestamp for signature
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      request.fields['timestamp'] = timestamp.toString();

      // Generate signature
      final signature = _generateSignature(timestamp, folder);
      request.fields['signature'] = signature;

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonData = json.decode(responseData);
        LoggerService.network('Video uploaded successfully to Cloudinary');
        return jsonData['secure_url'] as String;
      } else {
        LoggerService.error(
          'Cloudinary video upload failed with status: ${response.statusCode}',
          'CLOUDINARY',
        );
        return null;
      }
    } catch (e) {
      LoggerService.error('Error uploading video to Cloudinary', 'CLOUDINARY', e);
      return null;
    }
  }

  static Future<String?> uploadImageFromBytes(
    List<int> imageBytes,
    String fileName, {
    String? folder,
  }) async {
    try {
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', url);

      // Add the image bytes
      request.files.add(
        http.MultipartFile.fromBytes('file', imageBytes, filename: fileName),
      );

      // Add upload parameters
      request.fields['upload_preset'] = uploadPreset;
      request.fields['api_key'] = apiKey;

      if (folder != null) {
        request.fields['folder'] = folder;
      }

      // Add timestamp for signature
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      request.fields['timestamp'] = timestamp.toString();

      // Generate signature
      final signature = _generateSignature(timestamp, folder);
      request.fields['signature'] = signature;

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonData = json.decode(responseData);
        LoggerService.network(
          'Image bytes uploaded successfully to Cloudinary',
        );
        return jsonData['secure_url'] as String;
      } else {
        LoggerService.error(
          'Cloudinary upload failed with status: ${response.statusCode}',
          'CLOUDINARY',
        );
        return null;
      }
    } catch (e) {
      LoggerService.error('Error uploading to Cloudinary', 'CLOUDINARY', e);
      return null;
    }
  }

  static String _generateSignature(int timestamp, String? folder) {
    // Create the string to sign
    final paramsToSign = <String, String>{
      'timestamp': timestamp.toString(),
      'upload_preset': uploadPreset,
    };

    if (folder != null) {
      paramsToSign['folder'] = folder;
    }

    // Sort parameters alphabetically
    final sortedParams =
        paramsToSign.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

    // Create query string
    final queryString = sortedParams
        .map((entry) => '${entry.key}=${entry.value}')
        .join('&');

    // Add API secret
    final stringToSign = '$queryString$apiSecret';

    // Generate SHA1 hash
    final bytes = utf8.encode(stringToSign);
    final digest = sha1.convert(bytes);

    return digest.toString();
  }

  static Future<bool> deleteImage(String publicId) async {
    try {
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/destroy',
      );

      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Generate signature for deletion
      final paramsToSign = {
        'public_id': publicId,
        'timestamp': timestamp.toString(),
      };

      final sortedParams =
          paramsToSign.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

      final queryString = sortedParams
          .map((entry) => '${entry.key}=${entry.value}')
          .join('&');

      final stringToSign = '$queryString$apiSecret';
      final bytes = utf8.encode(stringToSign);
      final signature = sha1.convert(bytes).toString();

      final response = await http.post(
        url,
        body: {
          'public_id': publicId,
          'api_key': apiKey,
          'timestamp': timestamp.toString(),
          'signature': signature,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['result'] == 'ok';
      }

      return false;
    } catch (e) {
      LoggerService.error('Error deleting from Cloudinary', 'CLOUDINARY', e);
      return false;
    }
  }

  // Helper method to extract public ID from Cloudinary URL
  static String? getPublicIdFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;

      // Find the segment after 'upload' or 'image/upload'
      int uploadIndex = -1;
      for (int i = 0; i < pathSegments.length; i++) {
        if (pathSegments[i] == 'upload') {
          uploadIndex = i;
          break;
        }
      }

      if (uploadIndex != -1 && uploadIndex + 2 < pathSegments.length) {
        // Skip version (v1234567890) and get the public ID
        final publicIdWithExtension = pathSegments
            .sublist(uploadIndex + 2)
            .join('/');
        // Remove file extension
        final lastDotIndex = publicIdWithExtension.lastIndexOf('.');
        if (lastDotIndex != -1) {
          return publicIdWithExtension.substring(0, lastDotIndex);
        }
        return publicIdWithExtension;
      }

      return null;
    } catch (e) {
      LoggerService.error('Error extracting public ID', 'CLOUDINARY', e);
      return null;
    }
  }

  // Transform image URL for different sizes
  static String getTransformedUrl(
    String originalUrl, {
    int? width,
    int? height,
    String? crop = 'fill',
    String? quality = 'auto',
  }) {
    try {
      final uri = Uri.parse(originalUrl);
      final pathSegments = uri.pathSegments.toList();

      // Find upload segment
      int uploadIndex = -1;
      for (int i = 0; i < pathSegments.length; i++) {
        if (pathSegments[i] == 'upload') {
          uploadIndex = i;
          break;
        }
      }

      if (uploadIndex != -1) {
        // Build transformation string
        final transformations = <String>[];

        if (width != null) transformations.add('w_$width');
        if (height != null) transformations.add('h_$height');
        if (crop != null) transformations.add('c_$crop');
        if (quality != null) transformations.add('q_$quality');

        if (transformations.isNotEmpty) {
          pathSegments.insert(uploadIndex + 1, transformations.join(','));
        }

        return uri.replace(pathSegments: pathSegments).toString();
      }

      return originalUrl;
    } catch (e) {
      LoggerService.error('Error transforming URL', 'CLOUDINARY', e);
      return originalUrl;
    }
  }
}
