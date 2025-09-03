import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_user.dart';
import '../services/auth_provider.dart';
import '../services/follow_service.dart';
import '../services/communication_service.dart';

class UserTile extends StatefulWidget {
  final AppUser user;
  final VoidCallback onTap;
  final bool showFollowButton;

  const UserTile({
    super.key,
    required this.user,
    required this.onTap,
    this.showFollowButton = false,
  });

  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  bool _isFollowing = false;
  bool _isFollowLoading = false;
  bool _isCurrentUser = false;

  @override
  void initState() {
    super.initState();
    _checkIfCurrentUser();
    if (widget.showFollowButton && !_isCurrentUser) {
      _checkFollowStatus();
    }
  }

  void _checkIfCurrentUser() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _isCurrentUser = authProvider.appUser?.uid == widget.user.uid;
  }

  Future<void> _checkFollowStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.appUser;
    
    if (currentUser != null) {
      try {
        final isFollowing = await FollowService.isFollowing(
          followerId: currentUser.uid,
          followingId: widget.user.uid,
        );
        if (mounted) {
          setState(() {
            _isFollowing = isFollowing;
          });
        }
      } catch (e) {
        // Handle error silently
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Picture
          GestureDetector(
            onTap: widget.onTap,
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: widget.user.profileImageUrl != null
                  ? NetworkImage(widget.user.profileImageUrl!)
                  : null,
              child: widget.user.profileImageUrl == null
                  ? Text(
                      CommunicationService.getRoleIcon(widget.user.role),
                      style: const TextStyle(fontSize: 20),
                    )
                  : null,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // User Info
          Expanded(
            child: GestureDetector(
              onTap: widget.onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.user.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getRoleColor(widget.user.role),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          widget.user.role.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (widget.user.about != null && widget.user.about!.isNotEmpty)
                    Text(
                      widget.user.about!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  else if (widget.user.flatNo.isNotEmpty)
                    Text(
                      'Flat ${widget.user.flatNo}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Follow Button
          if (widget.showFollowButton && !_isCurrentUser) ...[
            const SizedBox(width: 12),
            _buildFollowButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildFollowButton() {
    return SizedBox(
      width: 80,
      height: 32,
      child: ElevatedButton(
        onPressed: _isFollowLoading ? null : _toggleFollow,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isFollowing ? Colors.grey.shade300 : const Color(0xFF4CAF50),
          foregroundColor: _isFollowing ? Colors.black : Colors.white,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isFollowLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                _isFollowing ? 'Unfollow' : 'Follow',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.purple;
      case 'vendor':
        return Colors.orange;
      case 'guard':
        return Colors.blue;
      case 'resident':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _toggleFollow() async {
    setState(() {
      _isFollowLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.appUser!;

      final newFollowStatus = await FollowService.toggleFollow(
        follower: currentUser,
        following: widget.user,
      );

      setState(() {
        _isFollowing = newFollowStatus;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newFollowStatus 
                  ? 'You are now following ${widget.user.name}'
                  : 'You unfollowed ${widget.user.name}',
            ),
            backgroundColor: const Color(0xFF4CAF50),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFollowLoading = false;
        });
      }
    }
  }
}
