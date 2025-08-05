import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'logger.dart';

class Helpers {
  // Color helpers
  static Color hexToColor(String hex) {
    assert(RegExp(r'^#([0-9a-fA-F]{6})|([0-9a-fA-F]{8})$').hasMatch(hex));
    return Color(int.parse(hex.substring(1), radix: 16) +
        (hex.length == 7 ? 0xFF000000 : 0x00000000));
  }

  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  // URL launcher
  static Future<void> launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Logger.error('Could not launch $url');
    }
  }

  static Future<void> launchEmail(String email,
      {String? subject, String? body}) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query: _encodeQueryParameters({
        if (subject != null) 'subject': subject,
        if (body != null) 'body': body,
      }),
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Logger.error('Could not launch email to $email');
    }
  }

  static String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(
        e.value)}')
        .join('&');
  }

  // Generate initials from name
  static String getInitials(String name) {
    if (name.isEmpty) return '';

    final words = name.trim().split(' ');
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    } else {
      return '${words[0][0]}${words[words.length - 1][0]}'.toUpperCase();
    }
  }

  // Generate random string
  static String generateId([int length = 8]) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime
        .now()
        .millisecondsSinceEpoch;
    return List.generate(length, (index) =>
    chars[(random + index) % chars.length]).join();
  }

  // Debounce function
  static Timer? _debounceTimer;

  static void debounce(VoidCallback callback,
      {Duration delay = const Duration(milliseconds: 500)}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, callback);
  }
}
