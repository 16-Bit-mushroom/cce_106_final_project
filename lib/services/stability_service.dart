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

  // --- 1. REVISED PROMPTS (Focus on Style, not Content) ---
  static final Map<String, String> stylePrompts = {
    "Anime":
        "anime style, cel shaded, vibrant colors, studio ghibli style, detailed linework, smooth textures",
    "Cyberpunk":
        "cyberpunk style, neon lighting overlay, high contrast, futuristic color palette, glowing edges",
    "Cartoon":
        "comic book art style, thick black outlines, flat colors, halftone dots, graphic novel aesthetic, expressive linework",
    "Sketch":
        "pencil sketch style, graphite texture, hatching, monochrome, rough paper texture, hand drawn strokes",
    "3D Model":
        "3d render style, clay material, blender 3d, smooth lighting, isometric look, soft shadows",
  };

  // --- 2. OFFICIAL PRESET MAPPING ---
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
    // --- CRITICAL FIX ---
    // 0.35 means "Change the image by 35%".
    // This keeps the original subject but applies the style.
    // Previous 0.75 was too high, causing it to generate new images.
    double strength = 0.35,
  }) async {
    try {
      print(
        '🚀 Starting Stability AI (Core) generation for: $style with strength $strength',
      );

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/v2beta/stable-image/generate/core'),
      );

      request.headers['Authorization'] = 'Bearer $_apiKey';
      request.headers['Accept'] = 'image/*';

      // 3. ADD THE OFFICIAL PRESET PARAMETER
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

      // Fix: Lower strength ensures we stick to the original photo
      request.fields['strength'] = strength.toStringAsFixed(2);

      request.fields['output_format'] = 'png';

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
