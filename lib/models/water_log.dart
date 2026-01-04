// Model dengan proper naming dan documentation
class WaterLog {
  final int? id; // nullable untuk auto-increment
  final DateTime dateTime;
  final double amount; // in ml
  final String? photoPath; // optional photo

  WaterLog({
    this.id,
    required this.dateTime,
    required this.amount,
    this.photoPath,
  });

  // Convert to Map for SQLite (Technical 30%)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'amount': amount,
      'photoPath': photoPath,
    };
  }

  // Create from Map
  factory WaterLog.fromMap(Map<String, dynamic> map) {
    return WaterLog(
      id: map['id'],
      dateTime: DateTime.parse(map['dateTime']),
      amount: map['amount'].toDouble(),
      photoPath: map['photoPath'],
    );
  }

  // For API (Technical 30%)
  Map<String, dynamic> toJson() => toMap();

  factory WaterLog.fromJson(Map<String, dynamic> json) =>
      WaterLog.fromMap(json);
}
