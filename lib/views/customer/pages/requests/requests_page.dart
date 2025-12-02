import 'package:flutter/material.dart';

class RequestsPage extends StatelessWidget {
  const RequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // MOCK DATA: Hardcoded list to simulate database results
    final List<Map<String, dynamic>> mockRequests = [
      {'id': 101, 'date': 'Dec 02, 2025', 'status': 'Pending', 'photo_count': 5},
      {'id': 100, 'date': 'Nov 28, 2025', 'status': 'Completed', 'photo_count': 3},
      {'id': 99,  'date': 'Nov 15, 2025', 'status': 'In Progress', 'photo_count': 12},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("My Requests")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockRequests.length,
        itemBuilder: (context, index) {
          final req = mockRequests[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getStatusColor(req['status']),
                child: const Icon(Icons.description, color: Colors.white, size: 20),
              ),
              title: Text("Request #${req['id']}"),
              subtitle: Text("${req['date']} • ${req['photo_count']} photos"),
              trailing: _buildStatusBadge(req['status']),
              onTap: () {
                // Open Detail Modal (We will create this next)
                _showRequestDetail(context, req);
              },
            ),
          );
        },
      ),
    );
  }

  // Helper to color-code status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending': return Colors.orange;
      case 'In Progress': return Colors.blue;
      case 'Completed': return Colors.green;
      default: return Colors.grey;
    }
  }

  // Helper to build the visual badge
  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor(status), width: 1),
      ),
      child: Text(
        status,
        style: TextStyle(color: _getStatusColor(status), fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showRequestDetail(BuildContext context, Map<String, dynamic> request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RequestDetailModal(request: request),
    );
  }
}

// Simple Mock Detail Modal
class _RequestDetailModal extends StatelessWidget {
  final Map<String, dynamic> request;
  const _RequestDetailModal({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 40, height: 4, color: Colors.grey[300]),
          ),
          const SizedBox(height: 20),
          Text("Request #${request['id']}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text("Status: ${request['status']}", style: const TextStyle(fontSize: 16)),
          const Divider(height: 30),
          const Text("Description", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          const Text("Please edit these photos to look cinematic and warm."),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {}, // This would open the gallery
              icon: const Icon(Icons.photo_library),
              label: const Text("View Photos"),
            ),
          )
        ],
      ),
    );
  }
}