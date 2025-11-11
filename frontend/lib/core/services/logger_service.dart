import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class AppLogger {
  static Logger? _logger;
  static bool _isInitialized = false;

  static void initialize({bool enableFileLogging = false}) {
    if (_isInitialized) return;

    _logger = Logger(
      printer: PrettyPrinter(),
      level: kDebugMode ? Level.debug : Level.warning,
    );

    _isInitialized = true;
  }

  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger?.d(message, error: error, stackTrace: stackTrace);
  }

  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger?.i(message, error: error, stackTrace: stackTrace);
  }

  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger?.w(message, error: error, stackTrace: stackTrace);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger?.e(message, error: error, stackTrace: stackTrace);
  }

  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger?.f(message, error: error, stackTrace: stackTrace);
  }
}
