import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class StabilityService {
  // ----------------  SECURITY WARNING  ----------------
  // Move this key to a backend before releasing to production.
  // ----------------------------------------------------
  static const String _apiKey =
      'sk-sSbsWwGCuKFZtnmIYqm17CGs2fRHoPOFwsgqOBckLuhSC2nu';

  // DOCUMENTATION SOURCE: Page 126-131 of your PDF (Control > Structure)
  static const String _baseUrl = 'https://api.stability.ai';

  // --- 1. REVISED PROMPTS (Descriptive backup for the preset) ---
  static final Map<String, String> stylePrompts = {
    "Anime":
        "anime artwork, studio ghibli style, vibrant colors, detailed line art",
    "Cyberpunk": "cyberpunk city style, neon lights, futuristic, high contrast",
    "Cartoon":
        "comic book style, thick black outlines, flat bold colors, halftone dots",
    "Sketch":
        "charcoal sketch, rough pencil lines, graphite texture, monochrome",
    "3D Model": "3d clay render, isometric, blender 3d, smooth lighting",
  };

  // --- 2. OFFICIAL PRESET MAPPING (Source: PDF Page 130) ---
  // These map strictly to the Stability AI 'Structure' endpoint enums.
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
    // control_strength (0.0 - 1.0):
    // 0.7 is the sweet spot. It forces the AI to keep the shape/layout of the photo
    // while allowing it to completely repaint the textures.
    double controlStrength = 0.7,
  }) async {
    try {
      print(
        '🚀 Starting Stability AI (Structure Control) generation for: $style',
      );

      // --- CRITICAL FIX: Use the 'Structure' endpoint ---
      // This endpoint preserves the geometry of the photo (faces, objects)
      // but repaints it in the requested style.
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/v2beta/stable-image/control/structure'),
      );

      request.headers['Authorization'] = 'Bearer $_apiKey';
      request.headers['Accept'] = 'image/*';

      // 1. Add the Style Preset (The most important part)
      if (_apiPresets.containsKey(style)) {
        request.fields['style_preset'] = _apiPresets[style]!;
      }

      // 2. Add the Image
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'original.jpg',
        ),
      );

      // 3. Add Parameters per PDF Page 128-130
      request.fields['prompt'] =
          stylePrompts[style] ?? "Apply $style style to this image";

      // 'control_strength' replaces 'strength' for this endpoint.
      // Default is 0.7. Lower = loose structure. Higher = strict structure.
      request.fields['control_strength'] = controlStrength.toStringAsFixed(2);

      request.fields['output_format'] = 'png';
      request.fields['seed'] = '0'; // 0 = Random seed

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
        // This will print the exact reason (e.g. "invalid_parameter")
        return null;
      }
    } catch (e) {
      print('💥 Exception: $e');
      return null;
    }
  }
}
