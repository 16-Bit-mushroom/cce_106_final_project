import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController(); // For Sender Name
  bool _isLoading = false;

  // --- SEVENTEEN Palette ---
  final Color color1 = const Color(0xFFf7cac9);
  final Color color2 = const Color(0xFFdec2cb);
  final Color color3 = const Color(0xFFc5b9cd);
  final Color color4 = const Color(0xFFabb1cf);
  final Color color5 = const Color(0xFF92a8d1);

  Future<void> _handleSignup() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final supabase = Supabase.instance.client;

    try {
      // 1. Create Auth User (The "Real" Login system)
      final response = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response.user != null) {
        // 2. Insert into Profiles (WITH PLAIN TEXT PASSWORD for Demo)
        await supabase.from('profiles').insert({
          'id': response.user!.id,
          'email': response.user!.email,
          'role': 'staff', // Default role
          'password': _passwordController.text.trim(), // <--- SAVING PLAIN TEXT
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created! Please log in.')),
          );
          Navigator.pop(context); // Go back to Login
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color1, color2, color3, color4, color5],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Branding
                Text(
                  "Join ComFie",
                  style: GoogleFonts.fredoka(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      const Shadow(
                          color: Colors.black12,
                          offset: Offset(0, 2),
                          blurRadius: 4)
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Glass Card
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.5), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: color5.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Full Name"),
                          _buildGlassTextField(_nameController, "e.g. Juan Cruz", Icons.person_outline),
                          const SizedBox(height: 16),
                          
                          _buildLabel("Email Address"),
                          _buildGlassTextField(_emailController, "name@email.com", Icons.email_outlined),
                          const SizedBox(height: 16),
                          
                          _buildLabel("Password"),
                          _buildGlassTextField(_passwordController, "Create password", Icons.lock_outline, isPassword: true),
                          const SizedBox(height: 16),

                          _buildLabel("Confirm Password"),
                          _buildGlassTextField(_confirmPasswordController, "Repeat password", Icons.lock_outline, isPassword: true),
                          const SizedBox(height: 32),

                          if (_isLoading)
                            const Center(child: CircularProgressIndicator(color: Colors.white))
                          else
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _handleSignup,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: color5,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          
                          const SizedBox(height: 16),
                          Center(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Already have an account? Log In", style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildGlassTextField(
      TextEditingController controller, String hint, IconData icon,
      {bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
          prefixIcon: Icon(icon, color: const Color(0xFF92a8d1)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}