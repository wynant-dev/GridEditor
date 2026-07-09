import 'package:flutter/foundation.dart';

/// A single recorded editor mutation for debug inspection.
class EditorActionEntry {
  const EditorActionEntry({
    required this.success,
    required this.message,
    required this.timestamp,
  });

  final bool success;
  final String message;
  final DateTime timestamp;
}

/// Ring buffer of recent editor actions.
class EditorActionLog extends ChangeNotifier {
  EditorActionLog({this.maxEntries = 100});

  final int maxEntries;
  final List<EditorActionEntry> _entries = [];

  List<EditorActionEntry> get entries => List.unmodifiable(_entries);

  void record({required bool success, required String message}) {
    _entries.insert(
      0,
      EditorActionEntry(
        success: success,
        message: message,
        timestamp: DateTime.now(),
      ),
    );
    if (_entries.length > maxEntries) {
      _entries.removeLast();
    }
    notifyListeners();
  }

  void clear() {
    if (_entries.isEmpty) return;
    _entries.clear();
    notifyListeners();
  }
}
