import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/complaint.dart';

class AdminComplaintsScreen extends StatefulWidget {
  const AdminComplaintsScreen({super.key});

  @override
  State<AdminComplaintsScreen> createState() => _AdminComplaintsScreenState();
}

class _AdminComplaintsScreenState extends State<AdminComplaintsScreen> {
  String _selectedFilter = 'all';
  final List<String> _statusFilters = [
    'all',
    'Open',
    'In Progress',
    'Resolved',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Complaint Management'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) => setState(() => _selectedFilter = value),
            itemBuilder: (context) => _statusFilters.map((filter) {
              return PopupMenuItem(
                value: filter,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _selectedFilter == filter
                          ? Icons.check
                          : Icons.circle_outlined,
                      size: 20.0,
                      color: _selectedFilter == filter ? Colors.blue : Colors.grey,
                    ),
                    const SizedBox(width: 8.0),
                    Text(filter.toUpperCase()),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Stats Cards
            Row(
              children: [
                Expanded(child: _buildStatCard('Total', Icons.list_alt, Colors.blue)),
                const SizedBox(width: 12.0),
                Expanded(child: _buildStatCard('Pending', Icons.pending, Colors.orange)),
                const SizedBox(width: 12.0),
                Expanded(child: _buildStatCard('Resolved', Icons.check_circle, Colors.green)),
              ],
            ),
            const SizedBox(height: 20.0),
            // Complaints List
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tap on any complaint card to view details, or use the menu (⋮) for more options',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            StreamBuilder<QuerySnapshot>(
              stream: _getComplaintsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 200.0,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.red,
                      ),
                    ),
                  );
                }

                final complaints = snapshot.data?.docs ?? [];

                if (complaints.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 64.0,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          'No complaints found',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: complaints.length,
                  itemBuilder: (context, index) {
                    final complaint = complaints[index];
                    final complaintObj = Complaint.fromFirestore(complaint);
                    return _buildComplaintCard(complaintObj);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, IconData icon, Color color) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('complaints').snapshots(),
      builder: (context, snapshot) {
        int count = 0;
        if (snapshot.hasData) {
          final complaints = snapshot.data!.docs;
          switch (title.toLowerCase()) {
            case 'total':
              count = complaints.length;
              break;
            case 'pending':
              count = complaints
                  .where((doc) =>
                      (doc.data() as Map<String, dynamic>)['status'] == 'Open')
                  .length;
              break;
            case 'resolved':
              count = complaints
                  .where((doc) =>
                      (doc.data() as Map<String, dynamic>)['status'] == 'Resolved')
                  .length;
              break;
          }
        }

        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: color,
                size: 24.0,
              ),
              const SizedBox(height: 8.0),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildComplaintCard(Complaint complaint) {
    final statusColor = Complaint.getStatusColor(complaint.status);
    final statusIcon = Complaint.getStatusIcon(complaint.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: () => _showComplaintDetails(complaint),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                complaint.category,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Flat ${complaint.flatNo}',
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (complaint.raisedByName.isNotEmpty)
              Text(
                'Raised by: ${complaint.raisedByName}',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              complaint.description,
              style: TextStyle(color: Colors.grey.shade600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          complaint.status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _formatDate(complaint.createdAt),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (complaint.updatedAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Updated: ${_formatDate(complaint.updatedAt!)}',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) => _handleComplaintAction(complaint.id, action, complaint),
          itemBuilder: (context) => [
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
            const PopupMenuItem(
              value: 'update_status',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Update Status'),
                ],
              ),
            ),
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

  Stream<QuerySnapshot> _getComplaintsStream() {
    Query query = FirebaseFirestore.instance.collection('complaints');

    // Handle status filtering with proper case matching
    if (_selectedFilter != 'all') {
      String filterStatus = _selectedFilter;
      // Convert filter to match database values
      switch (_selectedFilter.toLowerCase()) {
        case 'pending':
          filterStatus = 'Open';
          break;
        case 'in_progress':
          filterStatus = 'In Progress';
          break;
        case 'resolved':
          filterStatus = 'Resolved';
          break;
      }
      query = query.where('status', isEqualTo: filterStatus);
    }

    // Order by creation date (newest first)
    query = query.orderBy('created_at', descending: true);

    return query.snapshots();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _addSampleComplaints() async {
    try {
      final sampleComplaints = [
        {
          'raised_by': 'sample_user_1',
          'raised_by_name': 'John Doe',
          'flat_no': 'A-101',
          'category': 'Plumbing',
          'description': 'Water leakage in the bathroom. The tap is continuously dripping and causing water wastage.',
          'status': 'Open',
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        },
        {
          'raised_by': 'sample_user_2',
          'raised_by_name': 'Jane Smith',
          'flat_no': 'B-205',
          'category': 'Electrical',
          'description': 'Power outage in the living room. Multiple switches are not working properly.',
          'status': 'In Progress',
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        },
        {
          'raised_by': 'sample_user_3',
          'raised_by_name': 'Mike Johnson',
          'flat_no': 'C-302',
          'category': 'Maintenance',
          'description': 'Elevator is making strange noises and sometimes gets stuck between floors.',
          'status': 'Open',
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        },
        {
          'raised_by': 'sample_user_4',
          'raised_by_name': 'Sarah Wilson',
          'flat_no': 'A-104',
          'category': 'Security',
          'description': 'Main gate security camera is not working. Need immediate attention for safety.',
          'status': 'Resolved',
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        },
        {
          'raised_by': 'sample_user_5',
          'raised_by_name': 'David Brown',
          'flat_no': 'B-201',
          'category': 'Noise',
          'description': 'Loud music from neighboring flat during night hours. Disturbing sleep.',
          'status': 'In Progress',
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        },
      ];

      // Add each complaint to Firestore
      for (final complaint in sampleComplaints) {
        await FirebaseFirestore.instance.collection('complaints').add(complaint);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Sample complaints added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error adding sample complaints: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleComplaintAction(
    String complaintId,
    String action,
    Complaint complaint,
  ) {
    switch (action) {
      case 'view':
        _showComplaintDetails(complaint);
        break;
      case 'update_status':
        _showUpdateStatusDialog(complaintId, complaint.status);
        break;
      case 'delete':
        _showDeleteConfirmation(complaintId);
        break;
    }
  }

  void _showComplaintDetails(Complaint complaint) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${complaint.category} - Complaint Details'),
        contentPadding: const EdgeInsets.all(20),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Resident Information
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resident Information',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text('Name: ${complaint.raisedByName}'),
                    Text('Flat: ${complaint.flatNo}'),
                    Text('Submitted: ${_formatDate(complaint.createdAt)}'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Complaint Details
              const Text(
                'Category:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(complaint.category),
              const SizedBox(height: 12),

              const Text(
                'Description:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(complaint.description),
              const SizedBox(height: 12),

              const Text(
                'Status:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Complaint.getStatusColor(complaint.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Complaint.getStatusIcon(complaint.status),
                      size: 16,
                      color: Complaint.getStatusColor(complaint.status),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      complaint.status.toUpperCase(),
                      style: TextStyle(
                        color: Complaint.getStatusColor(complaint.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              if (complaint.updatedAt != null) ...[
                const SizedBox(height: 12),
                const Text(
                  'Last Updated:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(_formatDate(complaint.updatedAt!)),
              ],

              if (complaint.imageUrl != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Attached Image:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      complaint.imageUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        color: Colors.grey.shade200,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error, size: 40),
                            Text('Failed to load image'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
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

  void _showUpdateStatusDialog(String complaintId, String currentStatus) {
    String selectedStatus = currentStatus;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Open'),
                value: 'Open',
                groupValue: selectedStatus,
                onChanged: (value) => setState(() => selectedStatus = value!),
              ),
              RadioListTile<String>(
                title: const Text('In Progress'),
                value: 'In Progress',
                groupValue: selectedStatus,
                onChanged: (value) => setState(() => selectedStatus = value!),
              ),
              RadioListTile<String>(
                title: const Text('Resolved'),
                value: 'Resolved',
                groupValue: selectedStatus,
                onChanged: (value) => setState(() => selectedStatus = value!),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('complaints')
                  .doc(complaintId)
                  .update({
                    'status': selectedStatus,
                    'updated_at': FieldValue.serverTimestamp(),
                  });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Status updated successfully'),
                ),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(String complaintId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Complaint'),
        content: const Text(
          'Are you sure you want to delete this complaint? This action cannot be undone.',
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
                  .collection('complaints')
                  .doc(complaintId)
                  .delete();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Complaint deleted successfully'),
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
