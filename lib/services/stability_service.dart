import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class StabilityService {
  static const String _apiKey = 'sk-65YIHM2UAe6t1yhT85y6khBox2rr1dpdDSfHZhL0nx1Uxxjq';
  static const String _baseUrl = 'https://api.stability.ai';

  static final Map<String, String> stylePrompts = {
    "Anime": "transform into anime art style, vibrant colors, large expressive eyes, detailed hair, professional anime artwork, cel-shaded, Japanese animation, manga illustration, anime character art",
    "Oil Painting": "convert to oil painting style, visible brush strokes, rich texture, classical painting, Renaissance masterpiece, dramatic lighting, canvas texture, impasto technique, old masters style",
    "Cyberpunk": "transform into cyberpunk aesthetic, neon colors, futuristic elements, holographic displays, dystopian cityscape, glowing effects, technological enhancements, Blade Runner style, futuristic cybernetic",
    "Pixel Art": "convert to pixel art style, limited color palette, blocky retro video game aesthetics, 8-bit graphics, 16-bit sprite, dithering, video game art, retro gaming pixels",
    "Watercolor": "transform into watercolor painting, soft edges, transparent layers, beautiful color bleeds, delicate artwork, spontaneous brushwork, fluid colors, paper texture, watercolor wash",
    "Sketch": "convert to pencil sketch art, detailed line work, shading, cross-hatching, professional artist's sketch, hand-drawn illustration, charcoal drawing, monochrome sketch art",
    "Cartoon": "transform into cartoon illustration style, bold outlines, exaggerated features, bright solid colors, modern animation, clean lines, Disney animation style, animated series art",
    "Impressionist": "convert to impressionist painting, short brush strokes, emphasis on light, visible movement, Monet style, spontaneous, outdoor scene, color harmony, impressionism art",
    "Pop Art": "transform into pop art style, bold colors, Ben-Day dots, comic book aesthetics, Andy Warhol style, graphic art, commercial art, vibrant patterns, pop culture art",
  };

  static Future<Uint8List?> generateStyledImage({
    required Uint8List imageBytes,
    required String style,
    double strength = 0.7, // Start slightly lower than 0.85 for core model
  }) async {
    try {
      print('🚀 Starting Stability AI API call for style: $style (v2beta Core)');
      
      var request = http.MultipartRequest(
        'POST',
        // FIX 1: Switch to the modern v2beta Core model endpoint
        Uri.parse('$_baseUrl/v2beta/stable-image/generate/core'),
      );

      request.headers['Authorization'] = 'Bearer $_apiKey';
      // FIX 2: v2beta requires 'image/*' or 'application/json' for Accept
      request.headers['Accept'] = 'image/*'; 

      // FIX 3: v2beta requires the input image field name to be 'image'
      request.files.add(http.MultipartFile.fromBytes(
        'image', 
        imageBytes,
        filename: 'original.jpg',
      ));

      // FIX 4: v2beta requires the prompt field name to be 'prompt'
      request.fields['prompt'] = stylePrompts[style] ?? "Apply $style style to this image";
      
      // FIX 5: v2beta requires the strength field name to be 'strength'
      request.fields['strength'] = strength.toStringAsFixed(2);
      
      // 6. Add Negative Prompt (Essential for style control in v2beta as well)
      request.fields['negative_prompt'] = 'photorealistic, photo, low quality, bad composition, watermark, signature, ugly, deformed, blurry';
      
      // 7. Add output format field (required by v2beta)
      request.fields['output_format'] = 'png'; 
      
      // Optional: set the aspect ratio based on your input image dimensions 
      // (This will need to be calculated and sent, but we'll omit it for minimal change)
      // request.fields['aspect'] = '2:3'; 
      
      request.fields['cfg_scale'] = '7';
      request.fields['steps'] = '30';
      
      print('⏳ Sending request to Stability AI...');
      final response = await request.send();
      
      if (response.statusCode == 200) {
        final bytes = await response.stream.toBytes();
        print('✅ Successfully generated styled image: ${bytes.length} bytes');
        return bytes;
      } else {
        final errorBody = await response.stream.bytesToString();
        print('❌ Stability AI API error: ${response.statusCode}');
        print('❌ Error details: $errorBody');
        return null;
      }
    } catch (e) {
      print('💥 Error calling Stability AI API: $e');
      return null;
    }
  }

  // The diagnostic function for completeness
  static Future<Uint8List?> testTextToImage() async {
    try {
      print('🧪 Testing Stability AI Text-to-Image API...');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/v1/generation/stable-diffusion-xl-1024-v1-0/text-to-image'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'text_prompts': [{'text': 'A red cube floating in a blue cosmic void, digital art', 'weight': 1.0}],
          'cfg_scale': 7,
          'steps': 30,
          'samples': 1,
          'width': 1024,
          'height': 1024,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['artifacts'] != null && jsonResponse['artifacts'].isNotEmpty) {
          final base64Image = jsonResponse['artifacts'][0]['base64'];
          final bytes = base64.decode(base64Image);
          print('✅ Text-to-Image test PASSED. API key and endpoint are working.');
          return bytes;
        }
      }
      final errorBody = response.body;
      print('❌ Text-to-Image test FAILED: ${response.statusCode}');
      print('❌ Error details: $errorBody');
      return null;
    } catch (e) {
      print('💥 Text-to-Image test error: $e');
      return null;
    }
  }
  
  static Future<void> testApiConnection() async {}
}