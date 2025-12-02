import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class StabilityService {
  // ----------------  SECURITY WARNING  ----------------
  // 1. Go to your Stability AI dashboard and REVOKE your old key.
  // 2. Generate a NEW key.
  // 3. Paste your NEW key here for testing.
  // 4. Before you launch, move this to a backend (Firebase Functions).
  // ----------------------------------------------------
  static const String _apiKey =
      'sk-gq3CRbzNcfClxYUViP6rktlj1BakLUDDUzTvsVDxRoGSD6W6';

  static const String _baseUrl = 'https://api.stability.ai';

  // --- 1. REVISED & SIMPLIFIED STYLE LIST ---
  // We only keep styles that map to official Stability AI presets.
  // This ensures 100% consistency.
  static final Map<String, String> stylePrompts = {
    "Anime":
        "anime style, vibrant colors, expressive eyes, detailed hair, japanese animation, studio ghibli style, masterpiece",
    "Cyberpunk":
        "cyberpunk style, neon lights, futuristic, high tech, glowing elements, night city background, blade runner aesthetic",
    "Cartoon":
        "comic book style, bold outlines, flat colors, graphic novel aesthetic, superhero comic, expressive, clean lines",
    "Sketch":
        "line art style, pencil sketch, charcoal drawing, rough contours, hatching, monochrome, artistic draft, hand drawn",
    "3D Model":
        "3d model style, clay render, blender 3d, isometric, smooth textures, soft lighting, 3d character design, c4d",
  };

  // --- 2. OFFICIAL PRESET MAPPING ---
  // These map our UI names to Stability AI's internal "style_preset" enum.
  // Source: Stability AI Developer Platform Documentation
  static final Map<String, String> _apiPresets = {
    "Anime": "anime",
    "Cyberpunk": "neon-punk",
    "Cartoon": "comic-book",
    "Sketch": "line-art",
    "3D Model": "3d-model",
  };

  static Future<Uint8List?> generateStyledImage({
    required Uint8List imageBytes,
    required String style,
    double strength = 0.75, // Slightly increased for stronger effect
  }) async {
    try {
      print('🚀 Starting Stability AI (SD3) generation for: $style');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/v2beta/stable-image/generate/sd3'),
      );

      request.headers['Authorization'] = 'Bearer $_apiKey';
      request.headers['Accept'] = 'image/*';

      // Required for Image-to-Image
      request.fields['mode'] = 'image-to-image';

      // --- 3. ADD THE OFFICIAL PRESET PARAMETER ---
      // This is the "magic key" for consistency.
      if (_apiPresets.containsKey(style)) {
        request.fields['style_preset'] = _apiPresets[style]!;
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'original.jpg',
        ),
      );

      request.fields['prompt'] =
          stylePrompts[style] ?? "Apply $style style to this image";

      // strength: 0.0 = original image, 1.0 = full AI replacement
      // 0.75 is a sweet spot for "restyle but keep subject"
      request.fields['strength'] = strength.toStringAsFixed(2);

      request.fields['output_format'] = 'png';
      request.fields['model'] = 'sd3.5-large'; // Explicitly use the best model

      print('⏳ Sending request...');
      final response = await request.send();

      if (response.statusCode == 200) {
        final bytes = await response.stream.toBytes();
        print('✅ Success: ${bytes.length} bytes received.');
        return bytes;
      } else {
        final errorBody = await response.stream.bytesToString();
        print('❌ API Error: ${response.statusCode}');
        print('❌ Details: $errorBody');
        return null;
      }
    } catch (e) {
      print('💥 Exception: $e');
      return null;
    }
  }
}
