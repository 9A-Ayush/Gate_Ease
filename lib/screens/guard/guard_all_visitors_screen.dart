import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/responsive_utils.dart';

class GuardAllVisitorsScreen extends StatefulWidget {
  const GuardAllVisitorsScreen({super.key});

  @override
  State<GuardAllVisitorsScreen> createState() => _GuardAllVisitorsScreenState();
}

class _GuardAllVisitorsScreenState extends State<GuardAllVisitorsScreen> {
  String _selectedFilter = 'all';
  final List<String> _statusFilters = [
    'all',
    'pending',
    'approved',
    'denied',
    'checked_in',
    'checked_out',
  ];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'All Visitors',
          style: TextStyle(
            fontSize: ResponsiveUtils.getScaledFontSize(context, 20),
          ),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              Icons.filter_list,
              size: ResponsiveUtils.getScaledIconSize(context, 24),
            ),
            onSelected: (value) => setState(() => _selectedFilter = value),
            itemBuilder: (context) => _statusFilters.map((filter) {
              return PopupMenuItem(
                value: filter,
                child: Row(
                  children: [
                    Icon(
                      _selectedFilter == filter
                          ? Icons.check
                          : Icons.circle_outlined,
                      size: ResponsiveUtils.getScaledIconSize(context, 20),
                      color: _selectedFilter == filter
                                      ? Colors.green
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

          // Status Summary Cards
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('visitors').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();

                final visitors = snapshot.data!.docs;
                final pending =
                    visitors
                        .where(
                          (doc) =>
                              (doc.data() as Map<String, dynamic>)['status'] ==
                              'pending',
                        )
                        .length;
                final approved =
                    visitors
                        .where(
                          (doc) =>
                              (doc.data() as Map<String, dynamic>)['status'] ==
                              'approved',
                        )
                        .length;
                final checkedIn =
                    visitors
                        .where(
                          (doc) =>
                              (doc.data() as Map<String, dynamic>)['status'] ==
                              'checked_in',
                        )
                        .length;

                return LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate responsive height based on screen width
                    double cardHeight = constraints.maxWidth < 400 ? 60 : 70;

                    return SizedBox(
                      height: cardHeight,
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatusCard(
                              'Pending',
                              pending,
                              Colors.orange,
                              Icons.pending,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildStatusCard(
                              'Approved',
                              approved,
                              Colors.green,
                              Icons.check_circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildStatusCard(
                              'Checked In',
                              checkedIn,
                              Colors.blue,
                              Icons.login,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 16),

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

                // Filter by status in memory
                final statusFilteredVisitors =
                    _selectedFilter == 'all'
                        ? allVisitors
                        : allVisitors.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return data['status'] == _selectedFilter;
                        }).toList();

                // Filter by search query
                final filteredVisitors =
                    statusFilteredVisitors.where((doc) {
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

                // Sort by entry_time in memory
                filteredVisitors.sort((a, b) {
                  final aTime =
                      (a.data() as Map<String, dynamic>)['entry_time']
                          as Timestamp?;
                  final bTime =
                      (b.data() as Map<String, dynamic>)['entry_time']
                          as Timestamp?;
                  if (aTime == null && bTime == null) return 0;
                  if (aTime == null) return 1;
                  if (bTime == null) return -1;
                  return bTime.compareTo(aTime); // Descending order
                });

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
                              ? 'No ${_selectedFilter == 'all' ? '' : _selectedFilter} visitors found'
                              : 'No visitors found matching search',
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

  Widget _buildStatusCard(String title, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 7, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildVisitorCard(String visitorId, Map<String, dynamic> data) {
    final status = data['status'] ?? 'pending';
    final entryTime = data['entry_time'] as Timestamp?;
    final checkInTime = data['check_in_time'] as Timestamp?;

    Color statusColor = Colors.orange;
    IconData statusIcon = Icons.pending;
    String statusText = status.toUpperCase();

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
        statusText = 'AWAITING APPROVAL';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1),
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
                    color: statusColor.withValues(alpha: 0.1),
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
                            Icons.home,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Flat: ${data['visiting_flat'] ?? 'Unknown'}',
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
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Details Row
            Row(
              children: [
                Icon(Icons.phone, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  data['phone'] ?? 'No phone',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(width: 16),
                Icon(Icons.info_outline, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    data['purpose'] ?? 'No purpose',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Time Information
            Row(
              children: [
                Icon(Icons.schedule, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  entryTime != null
                      ? 'Logged: ${_formatDateTime(entryTime.toDate())}'
                      : 'No entry time',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                if (checkInTime != null) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.login, size: 14, color: Colors.green.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'In: ${_formatDateTime(checkInTime.toDate())}',
                    style: TextStyle(
                      color: Colors.green.shade600,
                      fontSize: 12,
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
