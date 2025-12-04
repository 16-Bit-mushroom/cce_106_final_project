import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cce_106_final_project/views/login_screen.dart';

class AdminScreen extends StatefulWidget {
  // We pass the role in so we know what to show
  final String currentUserRole;

  const AdminScreen({super.key, required this.currentUserRole});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  // --- ACTIONS ---

  // 1. Update User Role
  Future<void> _updateRole(String userId, String currentRole) async {
    String? selectedRole = currentRole;
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
                  DropdownMenuItem(value: 'user', child: Text('User')),
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
                  await Supabase.instance.client
                      .from('profiles')
                      .update({'role': selectedRole})
                      .eq('id', userId);
                  if (mounted) setState(() {}); // Refresh list
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // 2. Delete User (Note: This deletes from 'profiles'.
  // Real Auth deletion requires a backend Edge Function, but this works for MVP UI)
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
      await Supabase.instance.client.from('profiles').delete().eq('id', userId);
      if (mounted) setState(() {}); // Refresh list
    }
  }

  // 3. Log Out
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
            .order('role', ascending: true), // Sort by role
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
                      ? const Chip(
                          label: Text("You"),
                        ) // Can't delete/edit yourself easily
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
