import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/add_visitor_form.dart';

class AdminVisitorManagementScreen extends StatefulWidget {
  const AdminVisitorManagementScreen({super.key});

  @override
  State<AdminVisitorManagementScreen> createState() =>
      _AdminVisitorManagementScreenState();
}

class _AdminVisitorManagementScreenState
    extends State<AdminVisitorManagementScreen> {
  String _selectedFilter = 'all';
  final List<String> _statusFilters = [
    'all',
    'pending',
    'approved',
    'denied',
    'checked_in',
    'checked_out',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Visitor Management'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) => setState(() => _selectedFilter = value),
            itemBuilder:
                (context) =>
                    _statusFilters.map((filter) {
                      return PopupMenuItem(
                        value: filter,
                        child: Row(
                          children: [
                            Icon(
                              _selectedFilter == filter
                                  ? Icons.check
                                  : Icons.circle_outlined,
                              size: 20,
                              color:
                                  _selectedFilter == filter
                                      ? Colors.blue
                                      : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(filter.toUpperCase()),
                          ],
                        ),
                      );
                    }).toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Cards
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard('Total', Icons.people, Colors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Pending',
                    Icons.pending,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('Today', Icons.today, Colors.green),
                ),
              ],
            ),
          ),

          // Visitors List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getVisitorsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final visitors = snapshot.data?.docs ?? [];

                if (visitors.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No visitors found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: visitors.length,
                  itemBuilder: (context, index) {
                    final visitor = visitors[index];
                    final data = visitor.data() as Map<String, dynamic>;
                    return _buildVisitorCard(visitor.id, data);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddVisitorDialog(context),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Visitor'),
      ),
    );
  }

  Widget _buildStatCard(String title, IconData icon, Color color) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('visitors').snapshots(),
      builder: (context, snapshot) {
        int count = 0;
        if (snapshot.hasData) {
          final visitors = snapshot.data!.docs;
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          switch (title.toLowerCase()) {
            case 'total':
              count = visitors.length;
              break;
            case 'pending':
              count =
                  visitors
                      .where(
                        (doc) =>
                            (doc.data() as Map<String, dynamic>)['status'] ==
                            'pending',
                      )
                      .length;
              break;
            case 'today':
              count =
                  visitors.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final entryTime = data['entry_time'] as Timestamp?;
                    if (entryTime == null) return false;
                    final entryDate = entryTime.toDate();
                    return entryDate.isAfter(today);
                  }).length;
              break;
          }
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVisitorCard(String visitorId, Map<String, dynamic> data) {
    final status = data['status'] ?? 'pending';
    final entryTime = data['entry_time'] as Timestamp?;

    Color statusColor = Colors.orange;
    IconData statusIcon = Icons.pending;

    switch (status) {
      case 'approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'denied':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'checked_in':
        statusColor = Colors.blue;
        statusIcon = Icons.login;
        break;
      case 'checked_out':
        statusColor = Colors.purple;
        statusIcon = Icons.logout;
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child:
              data['photo_url'] != null
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.network(
                      data['photo_url'],
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) =>
                              Icon(statusIcon, color: statusColor),
                    ),
                  )
                  : Icon(statusIcon, color: statusColor),
        ),
        title: Text(
          data['name'] ?? 'Unknown Visitor',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.home, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'Flat: ${data['visiting_flat'] ?? 'Unknown'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.phone, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    data['phone'] ?? 'No phone',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (entryTime != null)
                  Flexible(
                    child: Text(
                      _formatDate(entryTime.toDate()),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) => _handleVisitorAction(visitorId, action, data),
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility, size: 20),
                      SizedBox(width: 8),
                      Text('View Details'),
                    ],
                  ),
                ),
                if (status == 'pending') ...[
                  const PopupMenuItem(
                    value: 'approve',
                    child: Row(
                      children: [
                        Icon(Icons.check, size: 20, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Approve'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'deny',
                    child: Row(
                      children: [
                        Icon(Icons.close, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Deny'),
                      ],
                    ),
                  ),
                ],
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
        ),
      ),
    );
  }

  Stream<QuerySnapshot> _getVisitorsStream() {
    Query query = FirebaseFirestore.instance
        .collection('visitors')
        .orderBy('entry_time', descending: true);

    if (_selectedFilter != 'all') {
      query = query.where('status', isEqualTo: _selectedFilter);
    }

    return query.snapshots();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _handleVisitorAction(
    String visitorId,
    String action,
    Map<String, dynamic> data,
  ) {
    switch (action) {
      case 'view':
        _showVisitorDetails(visitorId, data);
        break;
      case 'approve':
        _updateVisitorStatus(visitorId, 'approved');
        break;
      case 'deny':
        _updateVisitorStatus(visitorId, 'denied');
        break;
      case 'delete':
        _showDeleteConfirmation(visitorId);
        break;
    }
  }

  void _showVisitorDetails(String visitorId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(data['name'] ?? 'Visitor Details'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (data['photo_url'] != null) ...[
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(
                            data['photo_url'],
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) =>
                                    const Icon(Icons.person, size: 50),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _buildDetailRow('Phone', data['phone'] ?? 'Not provided'),
                  _buildDetailRow(
                    'Visiting Flat',
                    data['visiting_flat'] ?? 'Not specified',
                  ),
                  _buildDetailRow(
                    'Purpose',
                    data['purpose'] ?? 'Not specified',
                  ),
                  _buildDetailRow(
                    'Vehicle Type',
                    data['vehicle_type'] ?? 'None',
                  ),
                  _buildDetailRow('Status', data['status'] ?? 'Unknown'),
                  if (data['entry_time'] != null)
                    _buildDetailRow(
                      'Entry Time',
                      _formatDate((data['entry_time'] as Timestamp).toDate()),
                    ),
                  if (data['logged_by'] != null)
                    _buildDetailRow('Logged By', data['logged_by']),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _updateVisitorStatus(String visitorId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('visitors')
          .doc(visitorId)
          .update({
            'status': status,
            'updated_at': FieldValue.serverTimestamp(),
          });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Visitor ${status == 'approved' ? 'approved' : 'denied'} successfully',
          ),
          backgroundColor: status == 'approved' ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating visitor status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmation(String visitorId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Visitor'),
            content: const Text(
              'Are you sure you want to delete this visitor record? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('visitors')
                      .doc(visitorId)
                      .delete();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Visitor deleted successfully'),
                    ),
                  );
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _showAddVisitorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          child: SingleChildScrollView(
            child: AddVisitorForm(
              loggedBy: 'admin', // Admin can directly approve visitors
              onVisitorAdded: () {
                Navigator.of(context).pop(); // Close dialog
              },
            ),
          ),
        ),
      ),
    );
  }
}
