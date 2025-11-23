import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class StabilityService {
  // ----------------  SECURITY WARNING  ----------------
  // 1. Go to your Stability AI dashboard and REVOKE your old key.
  // 2. Generate a NEW key.
  // 3. Paste your NEW key here for testing.
  // 4. Before you launch your app, you MUST move this code to a
  //    backend (like a Firebase Function) to protect your key.
  // ----------------------------------------------------
  static const String _apiKey =
      'sk-YUaYsJOwcVrzeY9C26rtlcOtHaeegjmLULvtv4vd9BZilGq3';

  static const String _baseUrl = 'https://api.stability.ai';

  // Your style prompts are excellent and will work well.
  static final Map<String, String> stylePrompts = {
    "Anime":
        "transform into anime art style, vibrant colors, large expressive eyes, detailed hair, professional anime artwork, cel-shaded, Japanese animation, manga illustration, anime character art",
    "Oil Painting":
        "convert to oil painting style, visible brush strokes, rich texture, classical painting, Renaissance masterpiece, dramatic lighting, canvas texture, impasto technique, old masters style",
    "Cyberpunk":
        "transform into cyberpunk aesthetic, neon colors, futuristic elements, holographic displays, dystopian cityscape, glowing effects, technological enhancements, Blade Runner style, futuristic cybernetic",
    "Pixel Art":
        "convert to pixel art style, limited color palette, blocky retro video game aesthetics, 8-bit graphics, 16-bit sprite, dithering, video game art, retro gaming pixels",
    "Watercolor":
        "transform into watercolor painting, soft edges, transparent layers, beautiful color bleeds, delicate artwork, spontaneous brushwork, fluid colors, paper texture, watercolor wash",
    "Sketch":
        "convert to pencil sketch art, detailed line work, shading, cross-hatching, professional artist's sketch, hand-drawn illustration, charcoal drawing, monochrome sketch art",
    "Cartoon":
        "transform into cartoon illustration style, bold outlines, exaggerated features, bright solid colors, modern animation, clean lines, Disney animation style, animated series art",
    "Impressionist":
        "convert to impressionist painting, short brush strokes, emphasis on light, visible movement, Monet style, spontaneous, outdoor scene, color harmony, impressionism art",
    "Pop Art":
        "transform into pop art style, bold colors, Ben-Day dots, comic book aesthetics, Andy Warhol style, graphic art, commercial art, vibrant patterns, pop culture art",
  };

  static Future<Uint8List?> generateStyledImage({
    required Uint8List imageBytes,
    required String style,
    double strength = 0.7, // This is the 'strength' from the docs
  }) async {
    try {
      print(
        '🚀 Starting Stability AI API call for style: $style (v2beta SD3.5)',
      );

      // --- Use the correct Image-to-Image endpoint ---
      // This endpoint supports image-to-image.
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/v2beta/stable-image/generate/sd3'),
      );

      // Add API key and Accept headers
      request.headers['Authorization'] = 'Bearer $_apiKey';
      request.headers['Accept'] = 'image/*'; // We want raw image bytes back

      // --- Add the REQUIRED 'mode' parameter ---
      // The sd3 endpoint requires this to know you're doing img2img
      request.fields['mode'] = 'image-to-image';

      // --- These parameters are all correct for this endpoint ---

      // The input image
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'original.jpg',
        ),
      );

      // The text prompt
      request.fields['prompt'] =
          stylePrompts[style] ?? "Apply $style style to this image";

      // The strength parameter, required for img2img
      request.fields['strength'] = strength.toStringAsFixed(2);

      // Optional, but good to have
      request.fields['negative_prompt'] =
          'photorealistic, photo, low quality, bad composition, watermark, signature, ugly, deformed, blurry';

      // Specify the output format
      request.fields['output_format'] = 'png';

      // You can also specify the model if you want, e.g., sd3.5-medium
      // request.fields['model'] = 'sd3.5-medium';

      print('⏳ Sending request to Stability AI...');
      final response = await request.send();

      // Handle the response
      if (response.statusCode == 200) {
        final bytes = await response.stream.toBytes();
        print('✅ Successfully generated styled image: ${bytes.length} bytes');
        return bytes;
      } else {
        // If it's not 200, read the error message
        final errorBody = await response.stream.bytesToString();
        print('❌ Stability AI API error: ${response.statusCode}');
        print('❌ Error details: $errorBody');
        return null;
      }
    } catch (e) {
      // This is the ClientException (network error) you are seeing
      print('💥 Error calling Stability AI API: $e');
      return null;
    }
  }
}
