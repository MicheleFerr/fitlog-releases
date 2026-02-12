import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

/// Animated splash screen with Lottie fitness animation
/// Features smooth fade-out transition for natural feel
/// Reference: https://www.flutterclutter.dev/flutter/tutorials/beautiful-animated-splash-screen/
class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with TickerProviderStateMixin {
  // Lottie animation controller
  late AnimationController _lottieController;

  // Fade-out controller for smooth transition
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Audio player for intro sound
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Background color matching native splash
  static const Color _backgroundColor = Color(0xFF1B2838);

  @override
  void initState() {
    super.initState();

    // Set status bar to match splash
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: _backgroundColor,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    // Lottie controller - will be configured when animation loads
    _lottieController = AnimationController(vsync: this);

    // Fade-out controller for smooth transition to main app
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Smooth fade-out curve
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    // Listen for Lottie animation completion
    _lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        // Start fade-out animation
        _fadeController.forward();
      }
    });

    // Listen for fade-out completion
    _fadeController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        widget.onComplete();
      }
    });
  }

  void _onLottieLoaded(LottieComposition composition) {
    // Set duration and start animation ONLY after it's loaded
    _lottieController.duration = composition.duration;
    if (mounted) {
      _lottieController.forward();
      // Play intro sound synced with animation start
      _audioPlayer.play(AssetSource('sounds/app_intro.mp3'));
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _lottieController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          // Fade from 1.0 to 0.0
          opacity: 1.0 - _fadeAnimation.value,
          child: Scaffold(
            backgroundColor: _backgroundColor,
            body: Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: Lottie.asset(
                  'assets/animations/fitness_loading.json',
                  controller: _lottieController,
                  fit: BoxFit.contain,
                  onLoaded: _onLottieLoaded,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
