import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_provider.dart';
import '../../services/post_service.dart';
import '../../services/comment_service.dart';
import '../../services/like_service.dart';
import '../../models/post.dart';
import '../../models/comment.dart';
import '../../widgets/post_card.dart';
import '../../widgets/comment_item.dart';
import '../../widgets/responsive_widgets.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({
    super.key,
    required this.postId,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _commentFocusNode = FocusNode();
  bool _isAddingComment = false;

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.appUser;

    if (user == null) {
      return const ResponsiveScaffold(
        title: 'Post',
        body: Center(
          child: Text('Please log in to view this post'),
        ),
      );
    }

    return ResponsiveScaffold(
      title: 'Post',
      body: Column(
        children: [
          // Post Content
          Expanded(
            child: FutureBuilder<Post?>(
              future: PostService.getPostById(widget.postId),
              builder: (context, postSnapshot) {
                if (postSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF4CAF50),
                    ),
                  );
                }

                if (postSnapshot.hasError || !postSnapshot.hasData) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Post not found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final post = postSnapshot.data!;

                return SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    children: [
                      // Post Card
                      PostCard(
                        post: post,
                        currentUser: user,
                        onLike: () => _handleLike(post, user),
                        onComment: () => _focusCommentInput(),
                        onShare: () => _handleShare(post),
                        onUserTap: () => _handleUserTap(post.authorId),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Comments Section
                      StreamBuilder<List<Comment>>(
                        stream: CommentService.getPostComments(widget.postId),
                        builder: (context, commentsSnapshot) {
                          if (commentsSnapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32),
                                child: CircularProgressIndicator(
                                  color: Color(0xFF4CAF50),
                                ),
                              ),
                            );
                          }

                          final comments = commentsSnapshot.data ?? [];

                          if (comments.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.comment_outlined,
                                    size: 48,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No comments yet',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Be the first to comment!',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Text(
                                  'Comments (${comments.length})',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              ...comments.map((comment) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: CommentItem(
                                  comment: comment,
                                  currentUser: user,
                                  onUserTap: () => _handleUserTap(comment.userId),
                                ),
                              )),
                              const SizedBox(height: 80), // Space for comment input
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Comment Input
          _buildCommentInput(user),
        ],
      ),
    );
  }

  Widget _buildCommentInput(user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: user.profileImageUrl != null
                ? NetworkImage(user.profileImageUrl!)
                : null,
            child: user.profileImageUrl == null
                ? Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.grey.shade600,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _commentController,
              focusNode: _commentFocusNode,
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Color(0xFF4CAF50)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _isAddingComment ? null : _addComment,
            icon: _isAddingComment
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF4CAF50),
                    ),
                  )
                : const Icon(
                    Icons.send,
                    color: Color(0xFF4CAF50),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLike(Post post, user) async {
    try {
      await LikeService.toggleLike(
        postId: post.id,
        user: user,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleShare(Post post) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon!'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }

  void _handleUserTap(String userId) {
    Navigator.pushNamed(
      context,
      '/user_profile',
      arguments: userId,
    );
  }

  void _focusCommentInput() {
    _commentFocusNode.requestFocus();
  }

  Future<void> _addComment() async {
    final content = _commentController.text.trim();
    
    if (content.isEmpty) {
      return;
    }

    setState(() {
      _isAddingComment = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.appUser!;

      await CommentService.addComment(
        postId: widget.postId,
        content: content,
        user: user,
      );

      _commentController.clear();
      _commentFocusNode.unfocus();

      // Scroll to bottom to show new comment
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add comment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingComment = false;
        });
      }
    }
  }
}
