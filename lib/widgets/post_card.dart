import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/app_user.dart';
import '../services/like_service.dart';
import '../services/comment_service.dart';
import '../services/communication_service.dart';
// import '../widgets/video_player_widget.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostCard extends StatefulWidget {
  final Post post;
  final AppUser currentUser;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onUserTap;

  const PostCard({
    super.key,
    required this.post,
    required this.currentUser,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onUserTap,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isLiked = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLikeStatus();
  }

  Future<void> _checkLikeStatus() async {
    try {
      final isLiked = await LikeService.hasUserLikedPost(
        postId: widget.post.id,
        userId: widget.currentUser.uid,
      );
      if (mounted) {
        setState(() {
          _isLiked = isLiked;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          _buildPostHeader(),
          
          // Post Content
          if (widget.post.content.isNotEmpty) _buildPostContent(),
          
          // Post Images
          if (widget.post.imageUrls.isNotEmpty) _buildPostImages(),

          // Post Videos
          // if (widget.post.videoUrls.isNotEmpty) _buildPostVideos(),

          // Post Actions
          _buildPostActions(),
          
          // Post Stats
          _buildPostStats(),
        ],
      ),
    );
  }

  Widget _buildPostHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: widget.onUserTap,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: widget.post.authorProfileImageUrl != null
                  ? NetworkImage(widget.post.authorProfileImageUrl!)
                  : null,
              child: widget.post.authorProfileImageUrl == null
                  ? Text(
                      CommunicationService.getRoleIcon(widget.post.authorRole),
                      style: const TextStyle(fontSize: 16),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: widget.onUserTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.post.authorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        CommunicationService.getRoleIcon(widget.post.authorRole),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  Text(
                    timeago.format(widget.post.createdAt),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (widget.post.authorId == widget.currentUser.uid)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
              onSelected: (value) => _handlePostAction(value),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Edit'),
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
        ],
      ),
    );
  }

  Widget _buildPostContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Text(
        widget.post.content,
        style: const TextStyle(
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildPostImages() {
    if (widget.post.imageUrls.length == 1) {
      return Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxHeight: 400),
        child: Image.network(
          widget.post.imageUrls.first,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 200,
              color: Colors.grey.shade200,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              color: Colors.grey.shade200,
              child: const Center(
                child: Icon(Icons.error, color: Colors.grey),
              ),
            );
          },
        ),
      );
    } else {
      return SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: widget.post.imageUrls.length,
          itemBuilder: (context, index) {
            return Container(
              width: 150,
              margin: EdgeInsets.only(
                right: index < widget.post.imageUrls.length - 1 ? 8 : 0,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.post.imageUrls[index],
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.error, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      );
    }
  }

  // Widget _buildPostVideos() {
  //   return Column(
  //     children: widget.post.videoUrls.map((videoUrl) {
  //       return Container(
  //         width: double.infinity,
  //         constraints: const BoxConstraints(maxHeight: 400),
  //         margin: const EdgeInsets.only(bottom: 8),
  //         child: VideoPlayerWidget(
  //           videoUrl: videoUrl,
  //           showControls: true,
  //           autoPlay: false,
  //         ),
  //       );
  //     }).toList(),
  //   );
  // }

  Widget _buildPostActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: _isLoading ? null : _handleLike,
            icon: Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              color: _isLiked ? Colors.red : Colors.grey.shade600,
            ),
          ),
          IconButton(
            onPressed: widget.onComment,
            icon: Icon(
              Icons.comment_outlined,
              color: Colors.grey.shade600,
            ),
          ),
          IconButton(
            onPressed: widget.onShare,
            icon: Icon(
              Icons.share_outlined,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.post.likesCount > 0)
            Text(
              '${widget.post.likesCount} ${widget.post.likesCount == 1 ? 'like' : 'likes'}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          if (widget.post.commentsCount > 0)
            GestureDetector(
              onTap: widget.onComment,
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'View all ${widget.post.commentsCount} comments',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleLike() async {
    setState(() {
      _isLoading = true;
      _isLiked = !_isLiked; // Optimistic update
    });

    try {
      await LikeService.toggleLike(
        postId: widget.post.id,
        user: widget.currentUser,
      );
    } catch (e) {
      // Revert optimistic update on error
      setState(() {
        _isLiked = !_isLiked;
      });
      
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
          _isLoading = false;
        });
      }
    }
  }

  void _handlePostAction(String action) {
    switch (action) {
      case 'edit':
        // TODO: Implement edit post
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Edit post functionality coming soon!'),
          ),
        );
        break;
      case 'delete':
        _showDeleteConfirmation();
        break;
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement delete post
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Delete post functionality coming soon!'),
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
