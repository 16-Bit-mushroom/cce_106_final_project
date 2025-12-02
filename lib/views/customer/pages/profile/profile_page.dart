import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Mock User Data
  final TextEditingController _nameController = TextEditingController(text: "Jane Doe");
  final TextEditingController _emailController = TextEditingController(text: "jane@example.com");
  final TextEditingController _phoneController = TextEditingController(text: "+1 (555) 123-4567");
  
  // Password Controllers
  final TextEditingController _newPasswordController = TextEditingController(); 
  final TextEditingController _currentPasswordController = TextEditingController(); // NEW: Required for validation
  
  // Visibility States
  bool _obscureNewPassword = true;
  bool _obscureCurrentPassword = true; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile Management")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 1. Avatar Section
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage("https://i.pravatar.cc/300"), // Random mock avatar
                ),
                Container(
                  decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                    onPressed: () {
                      // Logic to pick new avatar
                    },
                  ),
                )
              ],
            ),
            const SizedBox(height: 30),

            // 2. Personal Information
            _buildSectionTitle("Personal Information"),
            
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Full Name", 
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 15),
            
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email", 
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Phone Number", 
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),

            const SizedBox(height: 30),

            // 3. Change Password Section
            _buildSectionTitle("Change Password"),

            TextField(
              controller: _newPasswordController,
              obscureText: _obscureNewPassword, 
              decoration: const InputDecoration(
                labelText: "New Password", 
                hintText: "Leave empty to keep current",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
                helperText: "Enter a new password ONLY if you want to change it",
              ).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNewPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 30),
            const Divider(thickness: 1),
            const SizedBox(height: 10),

            // 4. REQUIRED CONFIRMATION
            _buildSectionTitle("Confirm Changes"),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "To update any information (including name or email), you must enter your current password.",
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: _currentPasswordController,
              obscureText: _obscureCurrentPassword,
              decoration: const InputDecoration(
                labelText: "Current Password (Required)", 
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.vpn_key), 
                errorStyle: TextStyle(color: Colors.redAccent),
              ).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureCurrentPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureCurrentPassword = !_obscureCurrentPassword;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 5. Action Buttons
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  elevation: 2,
                ),
                onPressed: _handleSave,
                child: const Text("Save Changes", style: TextStyle(fontSize: 16)),
              ),
            ),
            
            const SizedBox(height: 15),
            
            TextButton(
              onPressed: () {
                // Logic to sign out
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text("Log Out", style: TextStyle(color: Colors.red)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 5),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
      ),
    );
  }

  void _handleSave() {
    // 1. Validate Current Password
    if (_currentPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("⚠️ You must enter your Current Password to save changes."),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        )
      );
      return;
    }

    // 2. Validate New Password logic (optional)
    if (_newPasswordController.text.isNotEmpty && _newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("New password must be at least 6 characters long."))
      );
      return;
    }

    // 3. Mock Success
    // In real app: verify password with Supabase here
    print("Saving Data...");
    print("Name: ${_nameController.text}");
    print("Current Password Used: ${_currentPasswordController.text}");
    
    // Clear passwords after save for security
    _currentPasswordController.clear();
    _newPasswordController.clear();
    FocusScope.of(context).unfocus(); // Close keyboard

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✅ Profile Updated Successfully"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      )
    );
  }
}