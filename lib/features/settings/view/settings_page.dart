import 'package:flutter/material.dart';
import 'package:pixora/features/settings/widgets/settings_footer.dart';
import 'package:pixora/features/settings/widgets/settings_section.dart';
import 'package:pixora/features/settings/widgets/settings_switch_tile.dart';
import 'package:pixora/features/settings/widgets/settings_top_bar.dart';

class CameraSettingsPage extends StatelessWidget {
  const CameraSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            /// 🔝 TOP HEADER
            const SettingsTopBar(),

            /// 🔽 SETTINGS CONTENT
            Expanded(
              child: ListView(
                children: const [
                  /// 🔹 GENERAL
                  SettingsSection(
                    title: "General",
                    children: [
                      SettingsSwitchTile(
                        title: "Shutter sound",
                        settingKey: "shutter_sound",
                        defaultValue: true,
                      ),
                      SettingsSwitchTile(
                        title: "Location",
                        subtitle:
                            "Show location info in photo and video details.",
                        settingKey: "location",
                        defaultValue: false,
                      ),
                      SettingsSwitchTile(
                        title: "Mirrored selfie",
                        subtitle:
                            "Keep the finished photo or video and the preview identical when using the front camera.",
                        settingKey: "mirror_selfie",
                        defaultValue: false,
                      ),
                      SettingsSwitchTile(
                        title: "Quick action for Camera",
                        subtitle:
                            "Double press the Volume down button to launch Camera when the screen is off.",
                        settingKey: "quick_launch",
                      ),
                    ],
                  ),

                  /// 🔹 PHOTO
                  SettingsSection(
                    title: "Photo",
                    children: [
                      SettingsSwitchTile(
                        title: "Finished photo orientation prompt",
                        settingKey: "orientation_prompt",
                      ),
                      SettingsSwitchTile(
                        title: "Histogram",
                        subtitle: "Work with Pro mode only.",
                        settingKey: "histogram",
                      ),
                      SettingsSwitchTile(
                        title: "QR code recognition",
                        subtitle:
                            "QR code can be recognized by the rear camera in Photo mode.",
                        settingKey: "qr_photo",
                      ),
                    ],
                  ),

                  /// 🔹 VIDEO
                  SettingsSection(
                    title: "Video",
                    children: [
                      SettingsSwitchTile(
                        title: "Off-screen recording",
                        subtitle:
                            "Automatically enter off-screen recording to extend duration.",
                        settingKey: "off_screen_recording",
                        defaultValue: false,
                      ),
                      SettingsSwitchTile(
                        title: "Lock white balance",
                        settingKey: "lock_wb",
                      ),
                    ],
                  ),

                  /// 🔹 FOOTER
                  SettingsFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
