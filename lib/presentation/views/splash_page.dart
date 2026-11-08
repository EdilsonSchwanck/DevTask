import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/task/task_bloc.dart';
import '../l10n/l10n.dart';
import 'home_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({
    super.key,
    this.duration = const Duration(milliseconds: 2600),
  });

  final Duration duration;

  static const Color brand = Color(0xFF3D5AFE);
  static const Color brandDeep = Color(0xFF1A237E);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoTurn;
  late final Animation<double> _check;
  late final Animation<double> _ring;
  late final Animation<double> _title;
  late final Animation<double> _tagline;
  late final Animation<double> _footer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _maybeContinue();
      });

    _logoScale = _interval(0.00, 0.40, Curves.elasticOut);
    _logoTurn = _interval(0.00, 0.35, Curves.easeOutBack);
    _check = _interval(0.30, 0.60, Curves.easeInOutCubic);
    _ring = _interval(0.45, 0.95, Curves.easeOutCubic);
    _title = _interval(0.50, 0.75, Curves.easeOutCubic);
    _tagline = _interval(0.62, 0.88, Curves.easeOutCubic);
    _footer = _interval(0.70, 1.00, Curves.easeOut);

    _controller.forward();
  }

  Animation<double> _interval(double begin, double end, Curve curve) =>
      CurvedAnimation(
        parent: _controller,
        curve: Interval(begin, end, curve: curve),
      );

  bool get _tasksLoaded {
    final status = context.read<TaskBloc>().state.status;
    return status == TaskStatus.ready || status == TaskStatus.failure;
  }

  void _maybeContinue() {
    if (_navigated || !mounted) return;
    if (!_controller.isCompleted || !_tasksLoaded) return;
    _navigated = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, _, _) => const HomePage(),
        transitionsBuilder: (_, animation, _, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween(begin: 1.05, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<TaskBloc, TaskState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (_, _) => _maybeContinue(),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          body: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = _controller.value;
              return DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [SplashPage.brand, SplashPage.brandDeep],
                  ),
                ),
                child: Stack(
                  children: [
                    // Slowly drifting decorative bubbles.
                    _Bubble(
                      alignment: Alignment(-1.25, -0.85 + 0.15 * t),
                      size: 240,
                      opacity: 0.08,
                    ),
                    _Bubble(
                      alignment: Alignment(1.3, 0.95 - 0.15 * t),
                      size: 300,
                      opacity: 0.06,
                    ),
                    _Bubble(
                      alignment: Alignment(0.95 - 0.1 * t, -1.1),
                      size: 120,
                      opacity: 0.10,
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox.square(
                            dimension: 200,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Pulse ring released when the check lands.
                                if (_ring.value > 0)
                                  Opacity(
                                    opacity: (1 - _ring.value) * 0.6,
                                    child: Transform.scale(
                                      scale: 0.9 + _ring.value * 0.9,
                                      child: Container(
                                        width: 116,
                                        height: 116,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            36,
                                          ),
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                Transform.rotate(
                                  angle: (1 - _logoTurn.value) * -math.pi / 5,
                                  child: Transform.scale(
                                    scale: _logoScale.value,
                                    child: _Logo(checkProgress: _check.value),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          _SlideFade(
                            value: _title.value,
                            offset: 24,
                            child: Text(
                              l10n.appTitle,
                              style: textTheme.displaySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _SlideFade(
                            value: _tagline.value,
                            offset: 16,
                            child: Text(
                              l10n.splashTagline,
                              textAlign: TextAlign.center,
                              style: textTheme.titleMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 56,
                      right: 56,
                      bottom: 64,
                      child: Opacity(
                        opacity: _footer.value,
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                key: const Key('splash-progress'),

                                value: _controller.isCompleted && !_tasksLoaded
                                    ? null
                                    : t,
                                minHeight: 4,
                                backgroundColor: Colors.white24,
                                valueColor: const AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.splashLoading,
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.checkProgress});

  final double checkProgress;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('splash-logo'),
      width: 116,
      height: 116,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 32,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _CheckPainter(
          progress: checkProgress,
          color: SplashPage.brand,
        ),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  _CheckPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final path = Path()
      ..moveTo(size.width * 0.27, size.height * 0.53)
      ..lineTo(size.width * 0.44, size.height * 0.69)
      ..lineTo(size.width * 0.75, size.height * 0.35);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final metric in path.computeMetrics()) {
      canvas.drawPath(
        metric.extractPath(0, metric.length * progress.clamp(0, 1)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_CheckPainter old) =>
      old.progress != progress || old.color != color;
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.alignment,
    required this.size,
    required this.opacity,
  });

  final Alignment alignment;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: opacity),
        ),
      ),
    );
  }
}

class _SlideFade extends StatelessWidget {
  const _SlideFade({
    required this.value,
    required this.offset,
    required this.child,
  });

  final double value;
  final double offset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: value.clamp(0, 1),
      child: Transform.translate(
        offset: Offset(0, offset * (1 - value)),
        child: child,
      ),
    );
  }
}
