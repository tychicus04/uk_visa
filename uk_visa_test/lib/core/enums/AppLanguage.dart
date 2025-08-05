enum AppLanguage {
  english('en', 'English', '🇬🇧'),
  vietnamese('vi', 'Tiếng Việt', '🇻🇳');

  const AppLanguage(this.code, this.name, this.flag);

  final String code;
  final String name;
  final String flag;

  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
          (lang) => lang.code == code,
      orElse: () => AppLanguage.english,
    );
  }
}