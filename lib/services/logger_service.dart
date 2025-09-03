import 'package:flutter/foundation.dart';

/// Log levels for different types of messages
enum LogLevel { debug, info, warning, error }

/// Professional logging service to replace print statements
/// Provides different log levels and better debugging capabilities
class LoggerService {
  static const String _tag = 'GateEase';

  /// Log a debug message (only in debug mode)
  static void debug(String message, [String? tag]) {
    if (kDebugMode) {
      _log(LogLevel.debug, message, tag);
    }
  }

  /// Log an info message
  static void info(String message, [String? tag]) {
    _log(LogLevel.info, message, tag);
  }

  /// Log a warning message
  static void warning(String message, [String? tag]) {
    _log(LogLevel.warning, message, tag);
  }

  /// Log an error message
  static void error(
    String message, [
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  ]) {
    _log(LogLevel.error, message, tag);
    if (error != null) {
      _log(LogLevel.error, 'Error details: $error', tag);
    }
    if (stackTrace != null && kDebugMode) {
      _log(LogLevel.error, 'Stack trace: $stackTrace', tag);
    }
  }

  /// Internal logging method
  static void _log(LogLevel level, String message, [String? tag]) {
    final timestamp = DateTime.now().toIso8601String();
    final logTag = tag ?? _tag;
    final levelStr = level.name.toUpperCase().padRight(7);

    // Format: [TIMESTAMP] [LEVEL] [TAG] Message
    final logMessage = '[$timestamp] [$levelStr] [$logTag] $message';

    // Use debugPrint for better performance in debug mode
    if (kDebugMode) {
      debugPrint(logMessage);
    } else {
      // In release mode, only log warnings and errors
      if (level == LogLevel.warning || level == LogLevel.error) {
        debugPrint(logMessage);
      }
    }
  }

  /// Log authentication events
  static void auth(String message) {
    info(message, 'AUTH');
  }

  /// Log database operations
  static void database(String message) {
    debug(message, 'DATABASE');
  }

  /// Log network operations
  static void network(String message) {
    debug(message, 'NETWORK');
  }

  /// Log UI events
  static void ui(String message) {
    debug(message, 'UI');
  }

  /// Log navigation events
  static void navigation(String message) {
    debug(message, 'NAVIGATION');
  }

  /// Log communication events (chat, notifications)
  static void communication(String message) {
    debug(message, 'COMMUNICATION');
  }

  /// Log vendor/business operations
  static void vendor(String message) {
    debug(message, 'VENDOR');
  }

  /// Log security events
  static void security(String message) {
    info(message, 'SECURITY');
  }

  /// Log payment operations
  static void payment(String message) {
    info(message, 'PAYMENT');
  }
}

/// Extension methods for easier logging
extension LoggerExtension on Object {
  /// Log this object as debug message
  void logDebug([String? tag]) {
    LoggerService.debug(toString(), tag);
  }

  /// Log this object as info message
  void logInfo([String? tag]) {
    LoggerService.info(toString(), tag);
  }

  /// Log this object as warning message
  void logWarning([String? tag]) {
    LoggerService.warning(toString(), tag);
  }

  /// Log this object as error message
  void logError([String? tag, StackTrace? stackTrace]) {
    LoggerService.error(toString(), tag, this, stackTrace);
  }
}
