import 'package:flutter/material.dart';

/// Dart convenience extensions
extension StringExtensions on String {
  /// Capitalize first letter
  String get capitalize => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Title case (capitalize each word)
  String get titleCase => split(' ').map((word) => word.capitalize).join(' ');

  /// Truncate with ellipsis
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}…';
  }
}

extension DateTimeExtensions on DateTime {
  /// Returns "2 days ago", "Just now", etc.
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return '${(diff.inDays / 30).floor()}mo ago';
  }

  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}

extension ContextExtensions on BuildContext {
  /// Screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Bottom padding (safe area)
  double get bottomPadding => MediaQuery.of(this).padding.bottom;
}

extension ListExtensions<T> on List<T> {
  /// Safe access by index, returns null if out of bounds
  T? safeAt(int index) => (index >= 0 && index < length) ? this[index] : null;
}
