import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cce_106_final_project/views/login_screen.dart';

class AdminScreen extends StatefulWidget {
  final String currentUserRole;
  const AdminScreen({super.key, required this.currentUserRole});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final Color color1 = const Color(0xFFf7cac9);
  final Color color2 = const Color(0xFFdec2cb);
  final Color color3 = const Color(0xFFc5b9cd);
  final Color color4 = const Color(0xFFabb1cf);
  final Color color5 = const Color(0xFF92a8d1);

  // --- EDIT PASSWORD LOGIC ---
  Future<void> _updatePasswordText(String userId, String currentPassword) async {
    final passCtrl = TextEditingController(text: currentPassword);
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit User Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Note: This updates the record for the presentation view.", style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 10),
            TextField(
              controller: passCtrl,
              decoration: const InputDecoration(labelText: "New Password", border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                // Update table
                await Supabase.instance.client
                    .from('profiles')
                    .update({'password': passCtrl.text}) // Update plain text
                    .eq('id', userId);
                
                // Try to update Auth if it's the CURRENT user
                final myId = Supabase.instance.client.auth.currentUser?.id;
                if(myId == userId) {
                   await Supabase.instance.client.auth.updateUser(UserAttributes(password: passCtrl.text));
                }

                if (mounted) {
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password record updated")));
                }
              } catch (e) {
                print(e);
              }
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  Future<void> _updateRole(String userId, String currentRole) async {
     String? selectedRole = currentRole;
    if (selectedRole == 'user') selectedRole = 'staff';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update Role"),
          content: StatefulBuilder(
            builder: (context, setStateSB) {
              return DropdownButton<String>(
                value: selectedRole,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'staff', child: Text('Staff')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (value) {
                  setStateSB(() => selectedRole = value);
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                if (selectedRole != null && selectedRole != currentRole) {
                  try {
                    await Supabase.instance.client
                        .from('profiles')
                        .update({'role': selectedRole})
                        .eq('id', userId);

                    if (mounted) {
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Role updated successfully"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                     // Handle error
                  }
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteUser(String userId) async {
      final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete User"),
        content: const Text("Are you sure? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await Supabase.instance.client
            .from('profiles')
            .delete()
            .eq('id', userId);
        if (mounted) setState(() {});
      } catch (e) {
         // handle error
      }
    }
  }
  
  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentUserRole != 'admin') {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(title: const Text("My Profile"), backgroundColor: Colors.transparent, elevation: 0, automaticallyImplyLeading: false,),
        body: Container(
          decoration: BoxDecoration(gradient: LinearGradient(colors: [color1, color2, color3, color4, color5])),
          child: Center(
            child: ElevatedButton(onPressed: _signOut, child: const Text("Logout")),
          ), 
        ),
      );
    }

    // 2. ADMIN VIEW (User Management)
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "User Management",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black12, blurRadius: 4)],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
              child: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
            ),
            onPressed: _signOut,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color1, color2, color3, color4, color5],
          ),
        ),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: Supabase.instance.client
              .from('profiles')
              .stream(primaryKey: ['id'])
              .order('role', ascending: true),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator(color: Colors.white.withOpacity(0.8)));
            }
            final users = snapshot.data!;
            
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 100, 24, 100),
              physics: const BouncingScrollPhysics(),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final email = user['email'] ?? 'No Email';
                final role = user['role'] ?? 'user';
                final password = user['password'] ?? 'Unknown';
                final userId = user['id'];
                
                final Color roleColor = role == 'admin' ? const Color(0xFF92a8d1) : const Color(0xFFF8B553);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.8)),
                    boxShadow: [BoxShadow(color: color5.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: ExpansionTile(
                    // FIX: REMOVE DEFAULT BORDERS
                    shape: const Border(), 
                    collapsedShape: const Border(),
                    // --------------------------
                    tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: roleColor.withOpacity(0.2), shape: BoxShape.circle),
                      child: Icon(role == 'admin' ? Icons.security_rounded : Icons.badge_rounded, color: roleColor, size: 24),
                    ),
                    title: Text(email, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 14)),
                    subtitle: Text(role.toUpperCase(), style: TextStyle(fontSize: 12, color: roleColor, fontWeight: FontWeight.w600)),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Password (DB Record):", style: TextStyle(fontSize: 10, color: Colors.grey)),
                                Text(password, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.key_rounded, color: Colors.orangeAccent),
                                  tooltip: "Edit Password",
                                  onPressed: () => _updatePasswordText(userId, password),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_rounded, color: Color(0xFF92a8d1)),
                                  tooltip: "Edit Role",
                                  onPressed: () => _updateRole(userId, role),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete_outline_rounded, color: Colors.red[300]),
                                  tooltip: "Delete User",
                                  onPressed: () => _deleteUser(userId),
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}