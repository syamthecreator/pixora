import 'package:flutter/material.dart';

class CameraMode {
  final IconData icon;
  final String label;
  final int index;

  const CameraMode({
    required this.icon,
    required this.label,
    required this.index,
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
    CameraMode(icon: Icons.photo_camera, label: "PHOTO", index: 0),
    CameraMode(icon: Icons.videocam, label: "VIDEO", index: 1),
    CameraMode(icon: Icons.slow_motion_video, label: "SLOW", index: 2),
  ];

  static CameraMode get photo => all[0];
  static CameraMode get video => all[1];
  static CameraMode get slowMotion => all[2];
}
