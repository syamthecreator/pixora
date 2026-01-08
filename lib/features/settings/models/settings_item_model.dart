class SettingsItem {
  final String title;
  final String? subtitle;
  final String keyName;
  final bool defaultValue;

  SettingsItem({
    required this.title,
    this.subtitle,
    required this.keyName,
    this.defaultValue = false,
  });
}
