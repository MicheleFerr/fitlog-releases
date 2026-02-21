import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Premium animated splash screen — Nothing/Apple minimal style.
/// Three glowing orbs converge from the edges and merge into the app logo,
/// followed by a staggered text reveal and a smooth fade-out.
class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _master;
  late final AnimationController _exitCtrl;
  late final Animation<double> _exitFade;

  final AudioPlayer _audioPlayer = AudioPlayer();

  static const _bg = Color(0xFF07080F);

  // Starting offsets of the orbs (px, relative to screen center)
  static const _orbStarts = [
    Offset(-160, -110), // top-left
    Offset(150, -130),  // top-right
    Offset(0, 155),     // bottom-center
  ];

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: _bg,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    // Total duration of the intro animation before fade-out begins
    _master = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _exitFade = CurvedAnimation(parent: _exitCtrl, curve: Curves.easeInOut);

    _exitCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) widget.onComplete();
    });

    // Play sound then start animation
    _audioPlayer.play(AssetSource('sounds/app_intro.mp3'));
    _master.forward().then((_) {
      if (mounted) _exitCtrl.forward();
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _master.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  /// Shorthand: create a curved sub-animation within the master timeline.
  Animation<double> _phase(double t0, double t1, {Curve curve = Curves.easeOut}) =>
      CurvedAnimation(
        parent: _master,
        curve: Interval(t0, t1, curve: curve),
      );

  @override
  Widget build(BuildContext context) {
    // Timeline phases (normalised 0..1 of the 3 s master)
    final orbMove   = _phase(0.00, 0.38, curve: Curves.easeInOut);
    final orbFade   = _phase(0.30, 0.46, curve: Curves.easeIn);
    final logoScale = _phase(0.38, 0.60, curve: Curves.elasticOut);
    final logoGlow  = _phase(0.52, 0.78, curve: Curves.easeInOut);
    final nameSlide = _phase(0.56, 0.74, curve: Curves.easeOut);
    final tagSlide  = _phase(0.70, 0.84, curve: Curves.easeOut);

    return AnimatedBuilder(
      animation: Listenable.merge([_master, _exitCtrl]),
      builder: (context, _) => Opacity(
        opacity: 1.0 - _exitFade.value,
        child: Scaffold(
          backgroundColor: _bg,
          body: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              // ── Ambient radial glow (pulses in once logo appears) ──────────
              Center(
                child: Opacity(
                  opacity: logoGlow.value * 0.28,
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [Color(0xFF3A6AFF), Colors.transparent],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Converging orbs ────────────────────────────────────────────
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    for (int i = 0; i < _orbStarts.length; i++)
                      _Orb(
                        start: _orbStarts[i],
                        moveProgress: orbMove.value,
                        fadeProgress: orbFade.value,
                        delayFraction: i * 0.08,
                      ),
                  ],
                ),
              ),

              // ── Logo con angoli chamfered (blooms dopo il merge) ──────────
              Center(
                child: Transform.scale(
                  scale: 0.55 + logoScale.value * 0.45,
                  child: Opacity(
                    opacity: logoScale.value.clamp(0.0, 1.0),
                    child: CustomPaint(
                      // Glow ring attorno alla sagoma chamfered
                      painter: _ChamferedGlowPainter(
                        glow: logoGlow.value,
                        size: 120,
                        cut: 22,
                      ),
                      child: ClipPath(
                        clipper: const _ChamferedClipper(cut: 22),
                        child: SizedBox(
                          width: 120,
                          height: 120,
                          child: Image.asset(
                            'assets/images/splash_logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── App name ──────────────────────────────────────────────────
              Align(
                alignment: const Alignment(0, 0.28),
                child: Opacity(
                  opacity: nameSlide.value,
                  child: Transform.translate(
                    offset: Offset(0, 18 * (1 - nameSlide.value)),
                    child: const Text(
                      'FitLog',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w200,
                        letterSpacing: 10,
                      ),
                    ),
                  ),
                ),
              ),

              // ── Tagline ───────────────────────────────────────────────────
              Align(
                alignment: const Alignment(0, 0.40),
                child: Opacity(
                  opacity: tagSlide.value,
                  child: Transform.translate(
                    offset: Offset(0, 12 * (1 - tagSlide.value)),
                    child: Text(
                      'TRAIN  WITH  PURPOSE',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Orb particle — moves from [start] to center and fades on merge
// ─────────────────────────────────────────────────────────────────────────────
class _Orb extends StatelessWidget {
  const _Orb({
    required this.start,
    required this.moveProgress,
    required this.fadeProgress,
    required this.delayFraction,
  });

  final Offset start;
  final double moveProgress;
  final double fadeProgress;
  final double delayFraction;

  @override
  Widget build(BuildContext context) {
    // Each orb starts moving slightly after the previous one
    final local =
        ((moveProgress - delayFraction) / (1.0 - delayFraction)).clamp(0.0, 1.0);
    final eased = Curves.easeInCubic.transform(local);
    final offset = Offset.lerp(start, Offset.zero, eased)!;
    final opacity = (local > 0 ? 1.0 : 0.0) * (1.0 - fadeProgress);

    return Transform.translate(
      offset: offset,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.7),
                blurRadius: 12,
                spreadRadius: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Clipper che taglia gli angoli a 45° (chamfered corners)
// ─────────────────────────────────────────────────────────────────────────────
class _ChamferedClipper extends CustomClipper<Path> {
  const _ChamferedClipper({required this.cut});
  final double cut;

  @override
  Path getClip(Size s) {
    return Path()
      ..moveTo(cut, 0)
      ..lineTo(s.width - cut, 0)
      ..lineTo(s.width, cut)
      ..lineTo(s.width, s.height - cut)
      ..lineTo(s.width - cut, s.height)
      ..lineTo(cut, s.height)
      ..lineTo(0, s.height - cut)
      ..lineTo(0, cut)
      ..close();
  }

  @override
  bool shouldReclip(_ChamferedClipper old) => old.cut != cut;
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter che disegna il bordo chamfered + glow attorno al logo
// ─────────────────────────────────────────────────────────────────────────────
class _ChamferedGlowPainter extends CustomPainter {
  const _ChamferedGlowPainter({
    required this.glow,
    required this.size,
    required this.cut,
  });
  final double glow;
  final double size;
  final double cut;

  Path _chamferedPath(double inset) {
    final w = size + inset * 2;
    final h = size + inset * 2;
    final c = cut - inset;
    return Path()
      ..moveTo(-inset + c, -inset)
      ..lineTo(-inset + w - c, -inset)
      ..lineTo(-inset + w, -inset + c)
      ..lineTo(-inset + w, -inset + h - c)
      ..lineTo(-inset + w - c, -inset + h)
      ..lineTo(-inset + c, -inset + h)
      ..lineTo(-inset, -inset + h - c)
      ..lineTo(-inset, -inset + c)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size _) {
    // Glow morbido esterno
    canvas.drawPath(
      _chamferedPath(8),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.07 * glow)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // Bordo netto
    canvas.drawPath(
      _chamferedPath(0),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(_ChamferedGlowPainter old) => old.glow != glow;
}
