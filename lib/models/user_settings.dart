class UserSettings {
  final double dailyTarget; // in ml
  final bool notificationsEnabled;
  final int reminderInterval; // in minutes

  UserSettings({
    this.dailyTarget = 2000.0,
    this.notificationsEnabled = true,
    this.reminderInterval = 60,
  });

  Map<String, dynamic> toMap() {
    return {
      'dailyTarget': dailyTarget,
      'notificationsEnabled': notificationsEnabled ? 1 : 0,
      'reminderInterval': reminderInterval,
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      dailyTarget: map['dailyTarget'],
      notificationsEnabled: map['notificationsEnabled'] == 1,
      reminderInterval: map['reminderInterval'],
    );
  }
}
