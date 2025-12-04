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
  // --- ACTIONS ---

  Future<void> _updateRole(String userId, String currentRole) async {
    String? selectedRole = currentRole;

    // Quick fix: If the current role is 'user' (from old data), default dropdown to 'staff'
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
                  // REMOVED: 'User' option is gone as requested.
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
                      setState(() {}); // Refresh list
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Role updated successfully"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Update failed: $e"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Delete failed: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
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
    // SECURITY CHECK: If not admin, just show Log Out
    if (widget.currentUserRole != 'admin') {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Profile"),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.badge, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text("Logged in as ${widget.currentUserRole.toUpperCase()}"),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text("Log Out"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: _signOut,
              ),
            ],
          ),
        ),
      );
    }

    // ADMIN VIEW
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Management"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Log Out",
            onPressed: _signOut,
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: Supabase.instance.client
            .from('profiles')
            .stream(primaryKey: ['id'])
            .order('role', ascending: true),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!;

          if (users.isEmpty) {
            return const Center(child: Text("No users found."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final email = user['email'] ?? 'No Email';
              final role = user['role'] ?? 'user';
              final userId = user['id'];
              final isMe =
                  Supabase.instance.client.auth.currentUser?.id == userId;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: role == 'admin'
                        ? Colors.deepPurple
                        : (role == 'staff' ? Colors.orange : Colors.grey),
                    child: Icon(
                      role == 'admin' ? Icons.security : Icons.person,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    email,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Role: ${role.toString().toUpperCase()}"),
                  trailing: isMe
                      ? const Chip(label: Text("You"))
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _updateRole(userId, role),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteUser(userId),
                            ),
                          ],
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
