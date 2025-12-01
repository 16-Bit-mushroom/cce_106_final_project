import 'package:cce_106_final_project/views/root_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // [1] Import this
import 'package:cce_106_final_project/views/login_screen.dart';

Future<void> main() async {
  // [2] Ensure Flutter bindings are initialized first
  WidgetsFlutterBinding.ensureInitialized();

  // [3] Initialize Supabase
  // Replace these with your actual values from the Supabase Dashboard
  await Supabase.initialize(
    url: 'https://mmkdrblmjvrsduikxutn.supabase.co',
    anonKey: 'sb_publishable_IQsFcQrNxdV1zC35_Zjh2g_jenJUiU3',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Styler App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}
