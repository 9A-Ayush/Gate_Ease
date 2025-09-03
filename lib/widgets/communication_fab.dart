import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/communication_service.dart';
import '../screens/common/contact_selection_screen.dart';
import '../screens/common/chat_list_screen.dart';

class CommunicationFAB extends StatefulWidget {
  const CommunicationFAB({super.key});

  @override
  State<CommunicationFAB> createState() => _CommunicationFABState();
}

class _CommunicationFABState extends State<CommunicationFAB>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.appUser;

    if (currentUser == null) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        // Full screen backdrop when expanded
        if (_isExpanded)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleExpanded,
              child: Container(color: Colors.black.withValues(alpha: 0.3)),
            ),
          ),
        // FAB content
        Positioned(
          bottom: 0,
          right: 0,
          child: _buildFABContent(context, currentUser),
        ),
      ],
    );
  }

  Widget _buildFABContent(BuildContext context, currentUser) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 400, // Limit the height of the FAB content
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
            // Emergency Broadcast (Admin only)
            if (currentUser.role == 'admin' && _isExpanded)
              Transform.scale(
                scale: _animation.value,
                child: Opacity(
                  opacity: _animation.value,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Emergency Broadcast',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 12),
                        FloatingActionButton(
                          heroTag: "emergency",
                          onPressed: () => _showEmergencyBroadcast(),
                          backgroundColor: Colors.red,
                          child: const Icon(
                            Icons.emergency,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // View All Chats
            if (_isExpanded)
              Transform.scale(
                scale: _animation.value,
                child: Opacity(
                  opacity: _animation.value,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'All Conversations',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 12),
                        FloatingActionButton(
                          heroTag: "all_chats",
                          onPressed: () {
                            _toggleExpanded();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ChatListScreen(),
                              ),
                            );
                          },
                          backgroundColor: Colors.blue,
                          child: const Icon(
                            Icons.chat_bubble,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Chat with all
            if (_isExpanded)
              Transform.scale(
                scale: _animation.value,
                child: Opacity(
                  opacity: _animation.value,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.teal,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Chat with all',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 12),
                        FloatingActionButton(
                          heroTag: "chat_with_all",
                          onPressed: () {
                            _toggleExpanded();
                            Navigator.pushNamed(context, '/simple_chat');
                          },
                          backgroundColor: Colors.teal,
                          child: const Icon(Icons.groups, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // New Chat
            if (_isExpanded)
              Transform.scale(
                scale: _animation.value,
                child: Opacity(
                  opacity: _animation.value,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'New Chat',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 12),
                        FloatingActionButton(
                          heroTag: "new_chat",
                          onPressed: () {
                            _toggleExpanded();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const ContactSelectionScreen(),
                              ),
                            );
                          },
                          backgroundColor: const Color(0xFF4CAF50),
                          child: const Icon(
                            Icons.person_add,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Main FAB
            StreamBuilder<int>(
              stream: CommunicationService.getUnreadMessageCount(
                currentUser.uid,
              ),
              builder: (context, snapshot) {
                final unreadCount = snapshot.data ?? 0;

                return Stack(
                  children: [
                    FloatingActionButton(
                      heroTag: "main_communication",
                      onPressed: _toggleExpanded,
                      backgroundColor: const Color(0xFF4CAF50),
                      child: AnimatedRotation(
                        turns: _isExpanded ? 0.125 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          _isExpanded ? Icons.close : Icons.chat,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEmergencyBroadcast() {
    _toggleExpanded();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emergency, color: Colors.red),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Emergency Broadcast',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            content: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 200, // Reduce to fit available space
                maxWidth: 300, // Reduce width more
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text(
                  'Send an emergency message to all users in the society.',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Emergency Message',
                    border: OutlineInputBorder(),
                    hintText: 'Enter emergency details...',
                  ),
                  maxLines: 2, // Reduce from 3 to 2 lines
                  onChanged: (value) {
                    // Store the message
                  },
                ),
                const SizedBox(height: 6),
                const Text(
                  'Select recipients:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Admin can broadcast to: Vendors, Residents, Guards',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  runSpacing: 2,
                  children: [
                    FilterChip(
                      label: const Text('Vendors', style: TextStyle(fontSize: 6)),
                      selected: true,
                      onSelected: (selected) {},
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    FilterChip(
                      label: const Text('Residents', style: TextStyle(fontSize: 6)),
                      selected: true,
                      onSelected: (selected) {},
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    FilterChip(
                      label: const Text('Guards', style: TextStyle(fontSize: 6)),
                      selected: true,
                      onSelected: (selected) {},
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Send emergency broadcast
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Emergency broadcast sent!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Send Emergency'),
              ),
            ],
          ),
    );
  }
}
