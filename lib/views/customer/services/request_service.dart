import 'dart:io';
import 'package:image_picker/image_picker.dart';
// import 'package:supabase_flutter/supabase_flutter.dart'; // Commented out for now

class RequestService {
  // We commented this out so the app doesn't crash without API keys
  // final SupabaseClient _supabase = Supabase.instance.client;

  // 1. Mock Request Creation
  Future<int> createRequestEntry(String description) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1)); 
    
    print("MOCK DB: Created request with description: $description");
    
    // Return a fake ID (e.g., 101)
    return 101; 
  }

  // 2. Mock Image Upload
  Future<String> uploadImage(XFile file, int requestId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    print("MOCK STORAGE: Uploading ${file.name} to Request #$requestId");
    
    // Return a fake URL
    return "https://via.placeholder.com/150"; 
  }

  // 3. Mock Linking Image
  Future<void> createRequestImageEntry(int requestId, String imageUrl) async {
    await Future.delayed(const Duration(milliseconds: 200));
    print("MOCK DB: Linked image $imageUrl to Request #$requestId");
  }
}