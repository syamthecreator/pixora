class WelcomeState {
  final bool isFirstLaunch;

  const WelcomeState({
    required this.isFirstLaunch,
  });

  WelcomeState copyWith({bool? isFirstLaunch}) {
    return WelcomeState(
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
    );
  }
}
