// lib/core/utils/extensions.dart
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }

  String toTitleCase() {
    return split(' ').map((word) => word.capitalize()).join(' ');
  }
}

extension DateTimeExtension on DateTime {
  String toFormattedString() {
    return '$day/${month.toString().padLeft(2, '0')}/$year';
  }

  String toTimeString() {
    final hour = this.hour.toString().padLeft(2, '0');
    final minute = this.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

extension ListExtension<T> on List<T> {
  List<T> get unique {
    final seen = <T>{};
    return where((element) => seen.add(element)).toList();
  }
}

