import 'package:image_picker/image_picker.dart';
import '../services/request_service.dart';

class RequestController {
  final RequestService _service = RequestService();

  Future<void> createNewRequest({
    required List<XFile> files,
    required String description,
  }) async {
    try {
      // A. Create the main request record
      final requestId = await _service.createRequestEntry(description);

      // B. Upload all images in parallel
      await Future.wait(files.map((file) async {
        final imageUrl = await _service.uploadImage(file, requestId);
        await _service.createRequestImageEntry(requestId, imageUrl);
      }));

      // C. (Optional) Trigger a notification or refresh the list
      
    } catch (e) {
      print("Error creating request: $e");
      rethrow; // Handle UI error showing in the View
    }
  }
}