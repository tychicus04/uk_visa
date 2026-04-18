// lib/core/constants/api_constants.dart
// Offline constants for language support

class ApiConstants {
  // Supported secondary languages for bilingual mode (offline)
  static const List<String> supportedSecondaryLanguages = [
    'vi', // Vietnamese
    'zh', // Chinese
    'ar', // Arabic
    'fr', // French
    'es', // Spanish
    'de', // German
    'it', // Italian
    'pt', // Portuguese
    'ru', // Russian
    'ja', // Japanese
    'hi', // Hindi
    'bn', // Bengali
    'ur', // Urdu
    'ta', // Tamil
    'te', // Telugu
    'pa', // Punjabi
    'pl', // Polish
    'ro', // Romanian
    'tr', // Turkish
    'th', // Thai
    'uk', // Ukrainian
    'ku', // Kurdish (Sorani)
    'sq', // Albanian
    'so', // Somali
    'am', // Amharic
    'tl', // Tagalog
    'ne', // Nepali
    'ti', // Tigrinya
  ];

  // Language flags
  static String getLanguageFlag(String code) {
    const flags = {
      'vi': '🇻🇳',
      'zh': '🇨🇳',
      'ar': '🇸🇦',
      'fr': '🇫🇷',
      'es': '🇪🇸',
      'de': '🇩🇪',
      'it': '🇮🇹',
      'pt': '🇵🇹',
      'ru': '🇷🇺',
      'ja': '🇯🇵',
      'hi': '🇮🇳',
      'bn': '🇧🇩',
      'ur': '🇵🇰',
      'ta': '🇮🇳',
      'te': '🇮🇳',
      'pa': '🇮🇳',
      'pl': '🇵🇱',
      'ro': '🇷🇴',
      'tr': '🇹🇷',
      'th': '🇹🇭',
      'uk': '🇺🇦',
      'ku': '🇮🇶',
      'sq': '🇦🇱',
      'so': '🇸🇴',
      'am': '🇪🇹',
      'tl': '🇵🇭',
      'ne': '🇳🇵',
      'ti': '🇪🇷',
    };
    return flags[code] ?? '🌐';
  }

  // Language names
  static String getLanguageName(String code) {
    const names = {
      'vi': 'Tiếng Việt',
      'zh': '中文',
      'ar': 'العربية',
      'fr': 'Français',
      'es': 'Español',
      'de': 'Deutsch',
      'it': 'Italiano',
      'pt': 'Português',
      'ru': 'Русский',
      'ja': '日本語',
      'hi': 'हिन्दी',
      'bn': 'বাংলা',
      'ur': 'اردو',
      'ta': 'தமிழ்',
      'te': 'తెలుగు',
      'pa': 'ਪੰਜਾਬੀ',
      'pl': 'Polski',
      'ro': 'Română',
      'tr': 'Türkçe',
      'th': 'ไทย',
      'uk': 'Українська',
      'ku': 'کوردی',
      'sq': 'Shqip',
      'so': 'Soomaali',
      'am': 'አማርኛ',
      'tl': 'Tagalog',
      'ne': 'नेपाली',
      'ti': 'ትግርኛ',
    };
    return names[code] ?? code.toUpperCase();
  }

  // Check if language is supported
  static bool isSupportedLanguage(String code) {
    return supportedSecondaryLanguages.contains(code);
  }
}
