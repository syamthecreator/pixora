import 'package:pixora/features/camera/controller/camera_controller.dart';
import 'package:pixora/features/settings/controller/settings_controller.dart';
import 'package:pixora/features/welcome/controller/welcome_controller.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';


class AppProviderBinding {
  static List<SingleChildWidget> get providers => [
    ChangeNotifierProvider(create: (_) => CameraControllerX()),
    ChangeNotifierProvider(create: (_) => SettingsController()),
    ChangeNotifierProvider(create: (_) => WelcomeController()),
  ];
}
