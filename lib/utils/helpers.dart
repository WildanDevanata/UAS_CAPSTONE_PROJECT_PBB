import 'package:intl/intl.dart';

class Helpers {
  // Format date dengan proper error handling
  static String formatDate(DateTime date) {
    try {
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  // Format time
  static String formatTime(DateTime time) {
    try {
      return DateFormat('HH:mm').format(time);
    } catch (e) {
      return 'Invalid Time';
    }
  }

  // Calculate progress percentage
  static double calculateProgress(double current, double target) {
    if (target == 0) return 0;
    return ((current / target) * 100).clamp(0.0, 100.0);
  }

  // Validate input (Code Quality - Error Handling)
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Jumlah tidak boleh kosong';
    }

    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return 'Jumlah harus lebih dari 0';
    }

    return null;
  }
}
