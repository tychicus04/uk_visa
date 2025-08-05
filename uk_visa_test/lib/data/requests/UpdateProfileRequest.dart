class UpdateProfileRequest {
  final String? fullName;
  final String? languageCode;

  UpdateProfileRequest({
    this.fullName,
    this.languageCode,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (fullName != null) data['full_name'] = fullName;
    if (languageCode != null) data['language_code'] = languageCode;
    return data;
  }
}