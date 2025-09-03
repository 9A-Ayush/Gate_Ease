import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_provider.dart';
import '../../services/user_service.dart';
import '../../services/post_service.dart';
import '../../services/follow_service.dart';
import '../../models/app_user.dart';
import '../../models/post.dart';
import '../../widgets/responsive_widgets.dart';
import '../../services/communication_service.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isFollowing = false;
  bool _isFollowLoading = false;
  bool _isCurrentUser = false;

  @override
  void initState() {
    super.initState();
    _checkIfCurrentUser();
    _checkFollowStatus();
  }

  void _checkIfCurrentUser() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _isCurrentUser = authProvider.appUser?.uid == widget.userId;
  }

  Future<void> _checkFollowStatus() async {
    if (_isCurrentUser) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.appUser;
    
    if (currentUser != null) {
      try {
        final isFollowing = await FollowService.isFollowing(
          followerId: currentUser.uid,
          followingId: widget.userId,
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
    return FutureBuilder<AppUser?>(
      future: UserService.getUserById(widget.userId),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const ResponsiveScaffold(
            title: 'Profile',
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4CAF50),
              ),
            ),
          );
        }

        if (userSnapshot.hasError || !userSnapshot.hasData) {
          return ResponsiveScaffold(
            title: 'Profile',
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_off,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'User not found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final user = userSnapshot.data!;

        return ResponsiveScaffold(
          title: user.name,
          body: Column(
            children: [
              // Profile Header
              _buildProfileHeader(user),
              
              // Posts Grid
              Expanded(
                child: _buildPostsGrid(user),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(AppUser user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        children: [
          // Profile Picture and Stats
          Row(
            children: [
              // Profile Picture
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: user.profileImageUrl != null
                    ? NetworkImage(user.profileImageUrl!)
                    : null,
                child: user.profileImageUrl == null
                    ? Text(
                        CommunicationService.getRoleIcon(user.role),
                        style: const TextStyle(fontSize: 32),
                      )
                    : null,
              ),
              
              const SizedBox(width: 20),
              
              // Stats
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn('Posts', _getPostsCount()),
                    _buildStatColumn('Followers', _getFollowersCount()),
                    _buildStatColumn('Following', _getFollowingCount()),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // User Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getRoleColor(user.role),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user.role.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (user.about != null && user.about!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  user.about!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
              if (user.flatNo.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Flat ${user.flatNo}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Action Buttons
          if (!_isCurrentUser) _buildFollowButton(),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, Widget countWidget) {
    return Column(
      children: [
        countWidget,
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _getPostsCount() {
    return StreamBuilder<List<Post>>(
      stream: PostService.getUserPosts(widget.userId),
      builder: (context, snapshot) {
        final count = snapshot.data?.length ?? 0;
        return Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        );
      },
    );
  }

  Widget _getFollowersCount() {
    return StreamBuilder<int>(
      stream: FollowService.getFollowersCount(widget.userId),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        );
      },
    );
  }

  Widget _getFollowingCount() {
    return StreamBuilder<int>(
      stream: FollowService.getFollowingCount(widget.userId),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        );
      },
    );
  }

  Widget _buildFollowButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isFollowLoading ? null : _toggleFollow,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isFollowing ? Colors.grey.shade300 : const Color(0xFF4CAF50),
          foregroundColor: _isFollowing ? Colors.black : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isFollowLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                _isFollowing ? 'Unfollow' : 'Follow',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildPostsGrid(AppUser user) {
    return StreamBuilder<List<Post>>(
      stream: PostService.getUserPosts(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF4CAF50),
            ),
          );
        }

        final posts = snapshot.data ?? [];

        if (posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.grid_on,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  _isCurrentUser ? 'No posts yet' : '${user.name} hasn\'t posted yet',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_isCurrentUser) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Share your first post!',
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

        return GridView.builder(
          padding: const EdgeInsets.all(1),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
          ),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return GestureDetector(
              onTap: () => Navigator.pushNamed(
                context,
                '/post_detail',
                arguments: post.id,
              ),
              child: Container(
                color: Colors.grey.shade200,
                child: post.imageUrls.isNotEmpty
                    ? Image.network(
                        post.imageUrls.first,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.error, color: Colors.grey),
                          );
                        },
                      )
                    : Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            post.content,
                            style: const TextStyle(fontSize: 12),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
              ),
            );
          },
        );
      },
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
      final targetUser = await UserService.getUserById(widget.userId);

      if (targetUser != null) {
        final newFollowStatus = await FollowService.toggleFollow(
          follower: currentUser,
          following: targetUser,
        );

        setState(() {
          _isFollowing = newFollowStatus;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                newFollowStatus 
                    ? 'You are now following ${targetUser.name}'
                    : 'You unfollowed ${targetUser.name}',
              ),
              backgroundColor: const Color(0xFF4CAF50),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
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
