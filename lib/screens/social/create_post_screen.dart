import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import '../../services/auth_provider.dart';
import '../../services/post_service.dart';
import '../../widgets/responsive_widgets.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final List<File> _selectedImages = [];
  // final List<File> _selectedVideos = [];
  // final List<VideoPlayerController> _videoControllers = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _contentController.dispose();
    // for (var controller in _videoControllers) {
    //   controller.dispose();
    // }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.appUser;

    if (user == null) {
      return const ResponsiveScaffold(
        title: 'Create Post',
        body: Center(
          child: Text('Please log in to create a post'),
        ),
      );
    }

    return ResponsiveScaffold(
      title: 'Create Post',
      actions: [
        TextButton(
          onPressed: _isLoading ? null : _publishPost,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Post',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ],
      body: Column(
        children: [
          // User Info Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: user.profileImageUrl != null
                      ? NetworkImage(user.profileImageUrl!)
                      : null,
                  child: user.profileImageUrl == null
                      ? Icon(
                          Icons.person,
                          color: Colors.grey.shade600,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      user.role.toUpperCase(),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content Input
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Text Input
                  Expanded(
                    child: TextField(
                      controller: _contentController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: const InputDecoration(
                        hintText: "What's on your mind?",
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),

                  // Selected Images Preview
                  if (_selectedImages.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 100,
                            margin: EdgeInsets.only(
                              right: index < _selectedImages.length - 1 ? 8 : 0,
                            ),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _selectedImages[index],
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  // Selected Videos Preview
                  // if (_selectedVideos.isNotEmpty) ...[
                  //   const SizedBox(height: 16),
                  //   SizedBox(
                  //     height: 100,
                  //     child: ListView.builder(
                  //       scrollDirection: Axis.horizontal,
                  //       itemCount: _selectedVideos.length,
                  //       itemBuilder: (context, index) {
                  //         return Container(
                  //           width: 100,
                  //           margin: EdgeInsets.only(
                  //             right: index < _selectedVideos.length - 1 ? 8 : 0,
                  //           ),
                  //           child: Stack(
                  //             children: [
                  //               ClipRRect(
                  //                 borderRadius: BorderRadius.circular(8),
                  //                 child: Container(
                  //                   width: 100,
                  //                   height: 100,
                  //                   color: Colors.black,
                  //                   child: _videoControllers[index].value.isInitialized
                  //                       ? AspectRatio(
                  //                           aspectRatio: _videoControllers[index].value.aspectRatio,
                  //                           child: VideoPlayer(_videoControllers[index]),
                  //                         )
                  //                       : const Center(
                  //                           child: CircularProgressIndicator(
                  //                             color: Colors.white,
                  //                           ),
                  //                         ),
                  //                 ),
                  //               ),
                  //               // Play icon overlay
                  //               const Positioned.fill(
                  //                 child: Center(
                  //                   child: Icon(
                  //                     Icons.play_circle_outline,
                  //                     color: Colors.white,
                  //                     size: 32,
                  //                   ),
                  //                 ),
                  //               ),
                  //               // Remove button
                  //               Positioned(
                  //                 top: 4,
                  //                 right: 4,
                  //                 child: GestureDetector(
                  //                   onTap: () => _removeVideo(index),
                  //                   child: Container(
                  //                     padding: const EdgeInsets.all(4),
                  //                     decoration: const BoxDecoration(
                  //                       color: Colors.black54,
                  //                       shape: BoxShape.circle,
                  //                     ),
                  //                     child: const Icon(
                  //                       Icons.close,
                  //                       color: Colors.white,
                  //                       size: 16,
                  //                     ),
                  //                   ),
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //         );
                  //       },
                  //     ),
                  //   ),
                  // ],
                ],
              ),
            ),
          ),

          // Bottom Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: _isLoading ? null : _pickImages,
                  icon: Icon(
                    Icons.photo_library,
                    color: _isLoading ? Colors.grey : const Color(0xFF4CAF50),
                  ),
                ),
                IconButton(
                  onPressed: _isLoading ? null : _takePhoto,
                  icon: Icon(
                    Icons.camera_alt,
                    color: _isLoading ? Colors.grey : const Color(0xFF4CAF50),
                  ),
                ),
                // IconButton(
                //   onPressed: _isLoading ? null : _pickVideo,
                //   icon: Icon(
                //     Icons.videocam,
                //     color: _isLoading ? Colors.grey : const Color(0xFF4CAF50),
                //   ),
                // ),
                const Spacer(),
                Text(
                  '${_contentController.text.length}/500',
                  style: TextStyle(
                    color: _contentController.text.length > 500
                        ? Colors.red
                        : Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        setState(() {
          for (var image in images) {
            if (_selectedImages.length < 5) {
              _selectedImages.add(File(image.path));
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick images: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null && _selectedImages.length < 5) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to take photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // Future<void> _pickVideo() async {
  //   try {
  //     final result = await FilePicker.platform.pickFiles(
  //       type: FileType.video,
  //       allowMultiple: false,
  //     );

  //     if (result != null && result.files.isNotEmpty) {
  //       final file = File(result.files.first.path!);

  //       // Check file size (limit to 50MB)
  //       final fileSize = await file.length();
  //       if (fileSize > 50 * 1024 * 1024) {
  //         if (mounted) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             const SnackBar(
  //               content: Text('Video file is too large. Please select a video under 50MB.'),
  //               backgroundColor: Colors.red,
  //             ),
  //           );
  //         }
  //         return;
  //       }

  //       if (_selectedVideos.length < 1) { // Limit to 1 video per post
  //         final controller = VideoPlayerController.file(file);
  //         await controller.initialize();

  //         setState(() {
  //           _selectedVideos.add(file);
  //           _videoControllers.add(controller);
  //         });
  //       } else {
  //         if (mounted) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             const SnackBar(
  //               content: Text('You can only add one video per post.'),
  //               backgroundColor: Colors.orange,
  //             ),
  //           );
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Failed to pick video: $e'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   }
  // }

  // void _removeVideo(int index) {
  //   setState(() {
  //     _videoControllers[index].dispose();
  //     _videoControllers.removeAt(index);
  //     _selectedVideos.removeAt(index);
  //   });
  // }

  Future<void> _publishPost() async {
    final content = _contentController.text.trim();
    
    if (content.isEmpty && _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add some content or images to your post'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (content.length > 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post content cannot exceed 500 characters'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.appUser!;

      await PostService.createPost(
        content: content,
        author: user,
        images: _selectedImages.isNotEmpty ? _selectedImages : null,
        // videos: _selectedVideos.isNotEmpty ? _selectedVideos : null,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post published successfully!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to publish post: $e'),
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
}
