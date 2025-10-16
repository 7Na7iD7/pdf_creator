import 'package:flutter/material.dart';

class AnimationProvider extends ChangeNotifier {
  bool _animationsEnabled = true;
  AnimationSpeed _animationSpeed = AnimationSpeed.normal;

  bool get animationsEnabled => _animationsEnabled;
  AnimationSpeed get animationSpeed => _animationSpeed;

  void toggleAnimations() {
    _animationsEnabled = !_animationsEnabled;
    notifyListeners();
  }

  void setAnimationSpeed(AnimationSpeed speed) {
    _animationSpeed = speed;
    notifyListeners();
  }

  Duration getAnimationDuration(Duration baseDuration) {
    if (!_animationsEnabled) return Duration.zero;

    switch (_animationSpeed) {
      case AnimationSpeed.slow:
        return baseDuration * 1.5;
      case AnimationSpeed.normal:
        return baseDuration;
      case AnimationSpeed.fast:
        return baseDuration * 0.7;
    }
  }
}

enum AnimationSpeed {
  slow,
  normal,
  fast,
}

extension AnimationSpeedExtension on AnimationSpeed {
  String get displayName {
    switch (this) {
      case AnimationSpeed.slow:
        return 'کند';
      case AnimationSpeed.normal:
        return 'عادی';
      case AnimationSpeed.fast:
        return 'سریع';
    }
  }
}