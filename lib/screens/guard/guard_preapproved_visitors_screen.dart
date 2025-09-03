import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GuardPreapprovedVisitorsScreen extends StatefulWidget {
  const GuardPreapprovedVisitorsScreen({super.key});

  @override
  State<GuardPreapprovedVisitorsScreen> createState() =>
      _GuardPreapprovedVisitorsScreenState();
}

class _GuardPreapprovedVisitorsScreenState
    extends State<GuardPreapprovedVisitorsScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Pre-approved Visitors'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, phone, or flat...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged:
                  (value) => setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),

          // Visitors List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('visitors').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final allVisitors = snapshot.data?.docs ?? [];

                // Filter for approved visitors from yesterday onwards (in memory)
                final yesterday = DateTime.now().subtract(
                  const Duration(days: 1),
                );
                final approvedVisitors =
                    allVisitors.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final status = data['status'] ?? '';
                      final visitDate = data['visit_date'] as Timestamp?;

                      // Check if status is approved and visit date is recent
                      if (status != 'approved') return false;
                      if (visitDate == null) {
                        return true; // Include if no date specified
                      }

                      return visitDate.toDate().isAfter(yesterday);
                    }).toList();

                // Sort by visit_date in memory
                approvedVisitors.sort((a, b) {
                  final aDate =
                      (a.data() as Map<String, dynamic>)['visit_date']
                          as Timestamp?;
                  final bDate =
                      (b.data() as Map<String, dynamic>)['visit_date']
                          as Timestamp?;
                  if (aDate == null && bDate == null) return 0;
                  if (aDate == null) return 1;
                  if (bDate == null) return -1;
                  return aDate.compareTo(bDate); // Ascending order
                });

                // Filter visitors based on search query
                final filteredVisitors =
                    approvedVisitors.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name =
                          (data['name'] ?? '').toString().toLowerCase();
                      final phone =
                          (data['phone'] ?? '').toString().toLowerCase();
                      final flat =
                          (data['visiting_flat'] ?? '')
                              .toString()
                              .toLowerCase();

                      return name.contains(_searchQuery) ||
                          phone.contains(_searchQuery) ||
                          flat.contains(_searchQuery);
                    }).toList();

                if (filteredVisitors.isEmpty) {
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
                          _searchQuery.isEmpty
                              ? 'No pre-approved visitors today'
                              : 'No visitors found matching search',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (_searchQuery.isEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Pre-approved visitors will appear here',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredVisitors.length,
                  itemBuilder: (context, index) {
                    final visitor = filteredVisitors[index];
                    final data = visitor.data() as Map<String, dynamic>;
                    return _buildVisitorCard(visitor.id, data);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitorCard(String visitorId, Map<String, dynamic> data) {
    final visitDate = data['visit_date'] as Timestamp?;
    final hasCheckedIn = data['checked_in'] == true;
    final checkInTime = data['check_in_time'] as Timestamp?;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasCheckedIn ? Colors.green.shade300 : Colors.grey.shade300,
          width: hasCheckedIn ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Visitor Photo or Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
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
                                      const Icon(Icons.person, size: 30),
                            ),
                          )
                          : const Icon(Icons.person, size: 30),
                ),
                const SizedBox(width: 12),

                // Visitor Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['name'] ?? 'Unknown Visitor',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            data['phone'] ?? 'No phone',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        hasCheckedIn
                            ? Colors.green.shade100
                            : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    hasCheckedIn ? 'CHECKED IN' : 'PENDING',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color:
                          hasCheckedIn
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Visit Details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.home, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'Visiting: ${data['visiting_flat'] ?? 'Unknown'}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        data['purpose'] ?? 'No purpose',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        visitDate != null
                            ? 'Expected: ${_formatDateTime(visitDate.toDate())}'
                            : 'No visit time',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      if (data['vehicle_type'] != null &&
                          data['vehicle_type'] != 'None') ...[
                        const Spacer(),
                        Icon(
                          Icons.directions_car,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          data['vehicle_type'],
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ],
                  ),
                  if (hasCheckedIn && checkInTime != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.login,
                          size: 16,
                          color: Colors.green.shade600,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Checked in: ${_formatDateTime(checkInTime.toDate())}',
                          style: TextStyle(
                            color: Colors.green.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Action Buttons
            Row(
              children: [
                if (!hasCheckedIn) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _checkInVisitor(visitorId, data),
                      icon: const Icon(Icons.login, size: 18),
                      label: const Text('CHECK IN'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showVisitorDetails(data),
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('VIEW'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                if (hasCheckedIn) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _checkOutVisitor(visitorId, data),
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text('CHECK OUT'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _checkInVisitor(String visitorId, Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance
          .collection('visitors')
          .doc(visitorId)
          .update({
            'checked_in': true,
            'check_in_time': FieldValue.serverTimestamp(),
            'status': 'checked_in',
          });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${data['name']} checked in successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking in visitor: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _checkOutVisitor(String visitorId, Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance
          .collection('visitors')
          .doc(visitorId)
          .update({
            'checked_out': true,
            'check_out_time': FieldValue.serverTimestamp(),
            'status': 'checked_out',
          });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${data['name']} checked out successfully'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking out visitor: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showVisitorDetails(Map<String, dynamic> data) {
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
                  if (data['visit_date'] != null)
                    _buildDetailRow(
                      'Expected Time',
                      _formatDateTime(
                        (data['visit_date'] as Timestamp).toDate(),
                      ),
                    ),
                  if (data['approved_by'] != null)
                    _buildDetailRow('Approved By', data['approved_by']),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
