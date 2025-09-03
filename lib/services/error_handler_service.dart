import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'logger_service.dart';

/// Enhanced error handling service for better user experience
class ErrorHandlerService {
  
  /// Handle Firebase Auth errors with user-friendly messages
  static String handleAuthError(dynamic error) {
    LoggerService.error('Auth error occurred', 'ERROR_HANDLER', error);
    
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No account found with this email address.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'email-already-in-use':
          return 'An account already exists with this email address.';
        case 'weak-password':
          return 'Password is too weak. Please choose a stronger password.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'user-disabled':
          return 'This account has been disabled. Please contact support.';
        case 'too-many-requests':
          return 'Too many failed attempts. Please try again later.';
        case 'operation-not-allowed':
          return 'This sign-in method is not enabled. Please contact support.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        default:
          return 'Authentication failed. Please try again.';
      }
    }
    
    return 'An unexpected error occurred. Please try again.';
  }

  /// Handle Firestore errors with user-friendly messages
  static String handleFirestoreError(dynamic error) {
    LoggerService.error('Firestore error occurred', 'ERROR_HANDLER', error);
    
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'You don\'t have permission to perform this action.';
        case 'unavailable':
          return 'Service temporarily unavailable. Please try again.';
        case 'deadline-exceeded':
          return 'Request timed out. Please check your connection.';
        case 'not-found':
          return 'Requested data not found.';
        case 'already-exists':
          return 'This data already exists.';
        case 'resource-exhausted':
          return 'Service limit exceeded. Please try again later.';
        case 'failed-precondition':
          return 'Operation failed due to invalid conditions.';
        case 'aborted':
          return 'Operation was aborted. Please try again.';
        case 'out-of-range':
          return 'Invalid data range provided.';
        case 'unimplemented':
          return 'This feature is not yet available.';
        case 'internal':
          return 'Internal server error. Please try again.';
        case 'data-loss':
          return 'Data corruption detected. Please contact support.';
        case 'unauthenticated':
          return 'Please log in to continue.';
        default:
          return 'Database error occurred. Please try again.';
      }
    }
    
    return 'An unexpected error occurred. Please try again.';
  }

  /// Handle network/HTTP errors
  static String handleNetworkError(dynamic error) {
    LoggerService.error('Network error occurred', 'ERROR_HANDLER', error);
    
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('socketexception') || 
        errorString.contains('network') ||
        errorString.contains('connection')) {
      return 'No internet connection. Please check your network.';
    }
    
    if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    
    if (errorString.contains('certificate') || 
        errorString.contains('ssl') ||
        errorString.contains('tls')) {
      return 'Secure connection failed. Please try again.';
    }
    
    return 'Network error occurred. Please check your connection.';
  }

  /// Handle image upload errors
  static String handleImageUploadError(dynamic error) {
    LoggerService.error('Image upload error occurred', 'ERROR_HANDLER', error);
    
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('file') || errorString.contains('image')) {
      return 'Failed to process image. Please try a different image.';
    }
    
    if (errorString.contains('size') || errorString.contains('large')) {
      return 'Image is too large. Please choose a smaller image.';
    }
    
    if (errorString.contains('format') || errorString.contains('type')) {
      return 'Unsupported image format. Please use JPG or PNG.';
    }
    
    return 'Failed to upload image. Please try again.';
  }

  /// Show error snackbar with consistent styling
  static void showErrorSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Show success snackbar with consistent styling
  static void showSuccessSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show warning snackbar with consistent styling
  static void showWarningSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_outlined, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show info snackbar with consistent styling
  static void showInfoSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Generic error handler that determines error type and shows appropriate message
  static void handleError(BuildContext context, dynamic error, {String? customMessage}) {
    String message = customMessage ?? 'An unexpected error occurred';
    
    if (error is FirebaseAuthException) {
      message = handleAuthError(error);
    } else if (error is FirebaseException) {
      message = handleFirestoreError(error);
    } else if (error.toString().toLowerCase().contains('network') ||
               error.toString().toLowerCase().contains('connection')) {
      message = handleNetworkError(error);
    } else if (error.toString().toLowerCase().contains('image') ||
               error.toString().toLowerCase().contains('upload')) {
      message = handleImageUploadError(error);
    }
    
    showErrorSnackBar(context, message);
  }
}
