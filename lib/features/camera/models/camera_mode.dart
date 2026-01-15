import 'package:flutter/material.dart';

class CameraMode {
  final IconData icon;
  final String label;
  final int index;
  final bool isEnabled; // 👈 NEW

  const CameraMode({
    required this.icon,
    required this.label,
    required this.index,
    this.isEnabled = true,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CameraMode &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          index == other.index;

  @override
  int get hashCode => label.hashCode ^ index.hashCode;

  @override
  String toString() => 'CameraMode(label: $label, index: $index)';
}

class CameraModes {
  static final List<CameraMode> all = [
    CameraMode(
      icon: Icons.photo_camera,
      label: "PHOTO",
      index: 0,
      isEnabled: true,
    ),
    CameraMode(
      icon: Icons.videocam,
      label: "VIDEO",
      index: 1,
      isEnabled: false,
    ),
  ];

  static CameraMode get photo => all[0];
  static CameraMode get video => all[1];
}
