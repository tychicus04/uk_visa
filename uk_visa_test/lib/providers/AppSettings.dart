class AppSettings {
  final bool soundEffects;
  final bool vibration;
  final bool biometricLogin;
  final bool autoLogin;
  final bool dataSync;
  final bool offlineMode;

  const AppSettings({
    this.soundEffects = true,
    this.vibration = true,
    this.biometricLogin = false,
    this.autoLogin = false,
    this.dataSync = true,
    this.offlineMode = false,
  });

  AppSettings copyWith({
    bool? soundEffects,
    bool? vibration,
    bool? biometricLogin,
    bool? autoLogin,
    bool? dataSync,
    bool? offlineMode,
  }) {
    return AppSettings(
      soundEffects: soundEffects ?? this.soundEffects,
      vibration: vibration ?? this.vibration,
      biometricLogin: biometricLogin ?? this.biometricLogin,
      autoLogin: autoLogin ?? this.autoLogin,
      dataSync: dataSync ?? this.dataSync,
      offlineMode: offlineMode ?? this.offlineMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'soundEffects': soundEffects,
      'vibration': vibration,
      'biometricLogin': biometricLogin,
      'autoLogin': autoLogin,
      'dataSync': dataSync,
      'offlineMode': offlineMode,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      soundEffects: json['soundEffects'] ?? true,
      vibration: json['vibration'] ?? true,
      biometricLogin: json['biometricLogin'] ?? false,
      autoLogin: json['autoLogin'] ?? false,
      dataSync: json['dataSync'] ?? true,
      offlineMode: json['offlineMode'] ?? false,
    );
  }
}