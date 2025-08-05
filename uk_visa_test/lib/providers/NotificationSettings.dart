class NotificationSettings {
  final bool pushNotifications;
  final bool emailNotifications;
  final bool studyReminders;
  final bool testReminders;
  final bool achievementNotifications;

  const NotificationSettings({
    this.pushNotifications = true,
    this.emailNotifications = true,
    this.studyReminders = true,
    this.testReminders = true,
    this.achievementNotifications = true,
  });

  NotificationSettings copyWith({
    bool? pushNotifications,
    bool? emailNotifications,
    bool? studyReminders,
    bool? testReminders,
    bool? achievementNotifications,
  }) {
    return NotificationSettings(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      studyReminders: studyReminders ?? this.studyReminders,
      testReminders: testReminders ?? this.testReminders,
      achievementNotifications: achievementNotifications ?? this.achievementNotifications,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pushNotifications': pushNotifications,
      'emailNotifications': emailNotifications,
      'studyReminders': studyReminders,
      'testReminders': testReminders,
      'achievementNotifications': achievementNotifications,
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      pushNotifications: json['pushNotifications'] ?? true,
      emailNotifications: json['emailNotifications'] ?? true,
      studyReminders: json['studyReminders'] ?? true,
      testReminders: json['testReminders'] ?? true,
      achievementNotifications: json['achievementNotifications'] ?? true,
    );
  }
}