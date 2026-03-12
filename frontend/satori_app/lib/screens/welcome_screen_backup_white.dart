// lib/screens/welcome_screen.dart
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../widgets/bounce.dart';

// ── Nav data ─────────────────────────────────────────────────────────
class _NavItem {
  final String label, emoji, sub, detail, route;
  final Color color, colorLight, shadowColor;
  final bool big;
  const _NavItem({
    required this.label, required this.emoji, required this.sub,
    required this.detail, required this.color, required this.colorLight,
    required this.shadowColor, required this.route, required this.big,
  });
}

const _items = [
  _NavItem(
    label: 'Pedidos', emoji: '📅', sub: 'Calendario & órdenes',
    detail: 'Gestiona tus pedidos del día',
    color: SatoriColors.teal, colorLight: SatoriColors.tealPale,
    shadowColor: SatoriColors.tealLight, route: '/pedidos', big: true,
  ),
  _NavItem(
    label: 'Punto de Venta', emoji: '🧾', sub: 'Cobros & productos',
    detail: 'Registra ventas al instante',
    color: SatoriColors.pinkPrimary, colorLight: SatoriColors.pinkPale,
    shadowColor: SatoriColors.pinkLight, route: '/venta', big: false,
  ),
  _NavItem(
    label: 'Predicción', emoji: '📈', sub: 'Tendencias de ventas',
    detail: 'Anticipa tu demanda',
    color: Color(0xFFE6A817), colorLight: Color(0xFFFFF8E1),
    shadowColor: Color(0xFFFFE082), route: '/prediccion', big: false,
  ),
];

// ════════════════════════════════════════════════════════════════════
// WELCOME SCREEN
// ════════════════════════════════════════════════════════════════════
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {

  late final AnimationController _ringCtrl;   // 9s loop — rings + particles
  late final AnimationController _blobCtrl;   // 14s ping-pong — aurora blobs
  late final AnimationController _entryCtrl;  // 1800ms one-shot — entrance

  late final Animation<double> _bgFade;
  late final Animation<double> _heroFade;
  late final Animation<Offset>  _heroSlide;
  final List<Animation<double>> _cardFades  = [];
  final List<Animation<double>> _cardScales = [];
  final List<Animation<Offset>>  _cardSlides = [];

  @override
  void initState() {
    super.initState();
    _ringCtrl  = AnimationController(vsync: this, duration: const Duration(seconds: 9))..repeat();
    _blobCtrl  = AnimationController(vsync: this, duration: const Duration(seconds: 14))..repeat(reverse: true);
    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));

    _bgFade   = CurvedAnimation(parent: _entryCtrl, curve: const Interval(0.0, 0.4, curve: Curves.easeOut));
    _heroFade = CurvedAnimation(parent: _entryCtrl, curve: const Interval(0.1, 0.55, curve: Curves.easeOutCubic));
    _heroSlide = Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero).animate(
      CurvedAnimation(parent: _entryCtrl, curve: const Interval(0.1, 0.55, curve: Curves.easeOutCubic)));

    for (int i = 0; i < _items.length; i++) {
      final s = 0.40 + i * 0.13;
      final e = (s + 0.38).clamp(0.0, 1.0);
      _cardFades.add(CurvedAnimation(parent: _entryCtrl, curve: Interval(s, e, curve: Curves.easeOut)));
      _cardScales.add(Tween<double>(begin: 0.80, end: 1).animate(
        CurvedAnimation(parent: _entryCtrl, curve: Interval(s, e, curve: Curves.elasticOut))));
      _cardSlides.add(Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
        CurvedAnimation(parent: _entryCtrl, curve: Interval(s, e, curve: Curves.easeOut))));
    }
    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    _blobCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  String _greetingLabel() {
    final h = DateTime.now().hour;
    if (h < 12) return '🌅 Buenos días';
    if (h < 18) return '☀️ Buenas tardes';
    return '🌙 Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F8), // Amanecer background
      body: Stack(
        children: [
          // ── 1. Aurora background ─────────────────────────
          Positioned.fill(child: _AuroraBackground(ctrl: _blobCtrl)),

          // ── 2. Full-screen ring field (background layer) ──
          Positioned.fill(
            child: AnimatedBuilder(
              animation: Listenable.merge([_ringCtrl, _bgFade]),
              builder: (_, __) => CustomPaint(
                painter: _GlobalRingsPainter(
                  angle: _ringCtrl.value * 2 * math.pi,
                  opacity: _bgFade.value,
                ),
              ),
            ),
          ),

          // ── 3. Particle field ─────────────────────────────
          Positioned.fill(
            child: AnimatedBuilder(
              animation: Listenable.merge([_ringCtrl, _bgFade]),
              builder: (_, __) => CustomPaint(
                painter: _ParticlePainter(
                  t: _ringCtrl.value,
                  opacity: _bgFade.value,
                ),
              ),
            ),
          ),

          // ── 4. Soft vignette ──────────────────────────────
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center, radius: 1.0,
                    colors: [
                      Colors.transparent,
                      const Color(0xFFFFF6F8).withAlpha(100),
                      const Color(0xFFFFF6F8).withAlpha(200),
                    ],
                    stops: const [0.35, 0.7, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // ── 5. Content (fixed header + scrollable body) ───
          Positioned.fill(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // FIXED HEADER
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                      child: Row(
                        children: [
                          FadeTransition(
                            opacity: _bgFade,
                            child: ShaderMask(
                              shaderCallback: (b) => const LinearGradient(
                                colors: [SatoriColors.pinkDeep, SatoriColors.tealDark],
                              ).createShader(b),
                              child: Text(
                                'Satori',
                                style: GoogleFonts.cormorantGaramond(
                                  fontSize: 26, fontWeight: FontWeight.w900,
                                  fontStyle: FontStyle.italic, color: Colors.white,
                                  letterSpacing: -1.0,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          // Greeting pill
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: AnimatedBuilder(
                                animation: _bgFade,
                                builder: (context, child) {
                                  final opacity = _bgFade.value;
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha((140 * opacity).round()),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.white.withAlpha((160 * opacity).round()), width: 1),
                                    ),
                                    child: Opacity(
                                      opacity: opacity,
                                      child: Text(_greetingLabel(), style: const TextStyle(
                                        fontSize: 11, fontWeight: FontWeight.w700,
                                        color: SatoriColors.textDark)),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                  ),
                ),

                // SCROLLABLE BODY
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(), // Fix Android overscroll stretch
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // ── Hero: logo + rings + title ────
                        FadeTransition(
                          opacity: _heroFade,
                          child: SlideTransition(
                            position: _heroSlide,
                            child: _HeroSection(ringCtrl: _ringCtrl),
                          ),
                        ),

                        // ── Subtle Illustration: Whisk ──
                        const SizedBox(height: 12),
                        AnimatedBuilder(
                          animation: _heroFade,
                          builder: (_, __) => _SubtleWhisk(opacity: _heroFade.value),
                        ),

                        const SizedBox(height: 32),

                        // ── Nav cards ─────────────────────
                        SizedBox(
                          height: 460,
                          child: Column(
                            children: [
                              Expanded(
                                flex: 5,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: _animatedCard(0),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Row(
                                  children: [
                                    for (int i = 1; i < _items.length; i++) ...[
                                      Expanded(child: _animatedCard(i)),
                                      if (i < _items.length - 1) const SizedBox(width: 14),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _animatedCard(int i) {
    return SlideTransition(
      position: _cardSlides[i],
      child: ScaleTransition(
        scale: _cardScales[i],
        child: _HoverNavCard(
          item: _items[i], 
          big: _items[i].big,
          entranceOpacity: _cardFades[i],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// HERO SECTION  — logo as centerpiece with local rings
// ════════════════════════════════════════════════════════════════════
class _HeroSection extends StatelessWidget {
  final AnimationController ringCtrl;
  const _HeroSection({super.key, required this.ringCtrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo + local rings ──────────────────────────────
        SizedBox(
          width: 220, height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Animated rings painted around logo center
              AnimatedBuilder(
                animation: ringCtrl,
                builder: (_, __) => CustomPaint(
                  painter: _LocalRingsPainter(angle: ringCtrl.value * 2 * math.pi),
                  child: const SizedBox(width: 220, height: 220),
                ),
              ),
              // Logo — STATIC
              Container(
                width: 96, height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: SatoriColors.pinkPrimary.withAlpha(60),
                      blurRadius: 24, offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: SatoriColors.teal.withAlpha(40),
                      blurRadius: 20, offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Center(child: Text('🎂', style: TextStyle(fontSize: 40))),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // "Satori"
        ShaderMask(
          shaderCallback: (b) => const LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [SatoriColors.pinkDeep, SatoriColors.textDark, SatoriColors.tealDark],
            stops: [0.0, 0.45, 1.0],
          ).createShader(b),
          child: Text(
            'Satori',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 80, fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic, color: Colors.white,
              letterSpacing: -4.0, height: 1.0,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Darker subtitle for accessibility
        const Text(
          'Gestión inteligente',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: SatoriColors.textDark, // Darker color
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// SUBTLE ILLUSTRATION  — Line art whisk to break monotony
// ════════════════════════════════════════════════════════════════════
class _SubtleWhisk extends StatelessWidget {
  final double opacity;
  const _SubtleWhisk({required this.opacity});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 60,
      child: CustomPaint(
        painter: _WhiskPainter(opacity: opacity),
      ),
    );
  }
}

class _WhiskPainter extends CustomPainter {
  final double opacity;
  _WhiskPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity < 0.01) return;
    final paint = Paint()
      ..color = SatoriColors.pinkPrimary.withAlpha((20 * opacity).round()) // Much lower opacity
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0 // Slimmer
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8) // Ultra-diffuse blur-3xl feel
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;

    // A simple whisk handle and loops
    path.moveTo(cx, cy + 20);
    path.lineTo(cx, cy - 10);

    // Whisk loops
    for (int i = 0; i < 3; i++) {
        final r = 6.0 + i * 4.0;
        path.addOval(Rect.fromCenter(center: Offset(cx, cy - 20), width: r, height: r * 2.5));
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WhiskPainter oldDelegate) => oldDelegate.opacity != opacity;
}

// Local rings around the logo (tight, pink/teal palette)
class _LocalRingsPainter extends CustomPainter {
  final double angle;
  _LocalRingsPainter({required this.angle});

  static const _colors = [SatoriColors.pinkPrimary, SatoriColors.teal, SatoriColors.tealLight];
  static const _radii  = [64.0, 84.0, 104.0];
  static const _opacities = [0.60, 0.42, 0.25];

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Glow behind logo
    canvas.drawCircle(
      Offset(cx, cy), 56,
      Paint()..shader = RadialGradient(colors: [
        SatoriColors.pinkPrimary.withAlpha(50), Colors.transparent,
      ]).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: 56)),
    );

    for (int i = 0; i < 3; i++) {
      final paint = Paint()
        ..color = _colors[i].withAlpha((_opacities[i] * 255).round())
        ..style = PaintingStyle.stroke
        ..strokeWidth = (1.8 - i * 0.4).clamp(0.5, 2.0);

      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(angle * (i.isEven ? 1 : -1) * (0.9 - i * 0.2));
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero,
            width: _radii[i] * 2, height: _radii[i] * 1.82),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_LocalRingsPainter o) => o.angle != angle;
}

// Global faint rings on the background
class _GlobalRingsPainter extends CustomPainter {
  final double angle;
  final double opacity;
  _GlobalRingsPainter({required this.angle, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity < 0.01) return;
    final cx = size.width / 2;
    final cy = size.height / 2;
    const baseR = 200.0;

    for (int i = 0; i < 3; i++) {
      final r = baseR + i * 80.0;
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(angle * (i.isEven ? 0.3 : -0.2));
      canvas.drawCircle(
        Offset.zero, r,
        Paint()
          ..color = SatoriColors.pinkLight.withAlpha((15 * opacity).round())
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_GlobalRingsPainter o) => o.angle != angle || o.opacity != opacity;
}

// Floating particles
class _ParticlePainter extends CustomPainter {
  final double t;
  final double opacity;
  _ParticlePainter({required this.t, required this.opacity});

  static final _pts = List.generate(18, (i) {
    final r = math.Random(i * 97 + 13);
    return (
      x: r.nextDouble(), y: r.nextDouble(),
      phase: r.nextDouble() * math.pi * 2,
      speed: 0.3 + r.nextDouble() * 0.4,
      size: 1.5 + r.nextDouble() * 2.0,
      colorIdx: i % 3,
    );
  });

  static const _colors = [SatoriColors.pinkPrimary, Color(0xFFFF8A80), Color(0xFFFFD166)];

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity < 0.01) return;
    for (final p in _pts) {
      final wave = math.sin(t * 1.5 * math.pi * p.speed + p.phase); // Slower, more organic
      final x = (p.x + 0.06 * math.cos(t * 1.2 * math.pi * p.speed + p.phase)) * size.width;
      final y = (p.y + 0.08 * wave) * size.height;
      final alpha = (((0.25 + 0.30 * (wave * 0.5 + 0.5)) * 255) * opacity).round();
      canvas.drawCircle(
        Offset(x, y), p.size,
        Paint()
          ..color = _colors[p.colorIdx].withAlpha(alpha.clamp(0, 255))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter o) => o.t != t || o.opacity != opacity;
}

// ════════════════════════════════════════════════════════════════════
// AURORA BACKGROUND  — pastel pink/cyan tones
// ════════════════════════════════════════════════════════════════════
class _AuroraBackground extends StatelessWidget {
  final AnimationController ctrl;
  const _AuroraBackground({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) {
        final t = ctrl.value;
        
        // Define our branded soft pastel colors
        final color1 = Color.lerp(SatoriColors.pinkPale, SatoriColors.yellowLight, (math.sin(t * math.pi * 2) + 1) / 2)!;
        final color2 = Color.lerp(SatoriColors.yellowLight, SatoriColors.tealPale, (math.cos(t * math.pi * 1.5) + 1) / 2)!;
        final color3 = Color.lerp(SatoriColors.tealLight.withValues(alpha: 0.6), SatoriColors.pinkLight, (math.sin(t * math.pi * 0.8) + 1) / 2)!;

        return Stack(
          children: [
            // Animated Soft Mesh Base
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [color1, color2, color3],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
            // Subtle Dot Grid pattern
            Positioned.fill(
              child: CustomPaint(
                painter: _DotGridPainter(),
              ),
            ),
            // Micro-Stars Layer
            Positioned.fill(
              child: CustomPaint(
                painter: _StarFieldPainter(t: t),
              ),
            ),
            // Aurora Blobs - Adjusted to complement the pastel mesh
            // Vibrant Rose blob
            _blob(550, const Color(0xFFFF758C), 0.28,
              left: -80 + 130 * math.sin(t * math.pi * 0.8),
              top: -100 + 90 * math.cos(t * math.pi * 0.7)),
            // Golden Amber blob
            _blob(500, const Color(0xFFFFD166), 0.25,
              right: -100 + 80 * math.cos(t * math.pi * 1.2),
              top: -40 + 110 * math.sin(t * math.pi * 0.9)),
            // Deep Fuchsia/Pink
            _blob(420, SatoriColors.pinkDeep, 0.20,
              left: -50 + 70 * math.sin(t * math.pi * 1.4),
              top: 220 + 90 * math.cos(t * math.pi)),
            // Soft Teal Highlight
            _blob(400, SatoriColors.teal, 0.22,
              right: 20 + 60 * math.sin(t * math.pi * 1.1),
              bottom: -60 + 70 * math.cos(t * math.pi * 0.8)),
            // Blur everything into smooth aurora
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
              child: Container(color: Colors.transparent),
            ),
          ],
        );
      },
    );
  }

  Widget _blob(double size, Color color, double opacity,
      {double? left, double? right, double? top, double? bottom}) {
    return Positioned(
      left: left, right: right, top: top, bottom: bottom,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [
            color.withAlpha((opacity * 255).round()), color.withAlpha(0),
          ]),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// SUBTLE DOT GRID BACKGROUND
// ════════════════════════════════════════════════════════════════════
class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SatoriColors.tealLight.withAlpha(20)
      ..style = PaintingStyle.fill;

    const spacing = 28.0;
    const radius = 1.2;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ════════════════════════════════════════════════════════════════════
// MICRO-STARS PAINTER
// ════════════════════════════════════════════════════════════════════
class _StarFieldPainter extends CustomPainter {
  final double t;
  _StarFieldPainter({required this.t});

  static final _stars = List.generate(40, (i) {
    final r = math.Random(i * 123 + 45);
    return (x: r.nextDouble(), y: r.nextDouble(), size: 0.3 + r.nextDouble() * 0.6, opacity: 0.2 + r.nextDouble() * 0.6);
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in _stars) {
      final twinkle = 0.7 + 0.3 * math.sin(t * 8 * math.pi + s.x * 100);
      final p = Paint()..color = Colors.white.withAlpha((s.opacity * twinkle * 255).round());
      canvas.drawCircle(Offset(s.x * size.width, s.y * size.height), s.size, p);
    }
  }

  @override
  bool shouldRepaint(_StarFieldPainter old) => old.t != t;
}

// ════════════════════════════════════════════════════════════════════
// HOVER NAV CARD
// ════════════════════════════════════════════════════════════════════
class _HoverNavCard extends StatefulWidget {
  final _NavItem item;
  final bool big;
  final Animation<double> entranceOpacity;
  const _HoverNavCard({required this.item, required this.big, required this.entranceOpacity});
  @override
  State<_HoverNavCard> createState() => _HoverNavCardState();
}

class _HoverNavCardState extends State<_HoverNavCard>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late final AnimationController _press;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.96, upperBound: 1.0, value: 1.0);
  }

  @override
  void dispose() { _press.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.entranceOpacity,
      builder: (context, child) {
        final item = widget.item;
        final opacity = widget.entranceOpacity.value;
        if (opacity < 0.01) return const SizedBox.shrink();

        return MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit:  (_) => setState(() => _hovered = false),
          cursor: SystemMouseCursors.click,
          child: SatoriBounce(
            onTap: () => context.go(item.route),
            child: AnimatedScale(
              scale: _hovered ? 1.03 : 1.0,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE2E8F0).withOpacity(_hovered ? 0.6 : 0.4),
                        blurRadius: _hovered ? 40 : 20,
                        offset: Offset(0, _hovered ? 12 : 6),
                        spreadRadius: _hovered ? 2 : 0,
                      ),
                    ],
                  ),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: _hovered ? 30 : 20, sigmaY: _hovered ? 30 : 20),
                    child: Container(
                      width: double.infinity, height: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(_hovered ? 130 : 100),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: Colors.white.withOpacity(_hovered ? 0.5 : 0.35),
                            width: 1.5,
                          ),
                        ),
                      child: Opacity(
                        opacity: opacity,
                        child: Stack(
                          children: [
                            Positioned(
                              right: -30, top: -30,
                              child: Container(
                                width: 100, height: 100,
                                decoration: BoxDecoration(
                                  color: item.color.withAlpha(20),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 400),
                              right: _hovered ? -6 : -20, bottom: _hovered ? -6 : -20,
                              child: Container(
                                width: widget.big ? 120 : 85, height: widget.big ? 120 : 85,
                                decoration: BoxDecoration(
                                  color: item.color.withAlpha(16), shape: BoxShape.circle),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(widget.big ? 22 : 17),
                              child: widget.big
                                  ? _BigContent(item: item, hovered: _hovered)
                                  : _SmallContent(item: item, hovered: _hovered),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BigContent extends StatelessWidget {
  final _NavItem item;
  final bool hovered;
  const _BigContent({required this.item, required this.hovered});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              width: 62, height: 62,
              decoration: BoxDecoration(
                color: item.color, borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: item.color.withAlpha(hovered ? 130 : 80),
                  blurRadius: hovered ? 18 : 10, offset: Offset(0, hovered ? 8 : 4))],
              ),
              child: Center(child: Text(item.emoji, style: const TextStyle(fontSize: 30))),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: hovered ? item.color : item.color.withAlpha(28),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('Explorar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                    color: hovered ? Colors.white : item.color)),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, size: 15,
                    color: hovered ? Colors.white : item.color),
              ]),
            ),
          ],
        ),
        const Spacer(),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 160),
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900,
              color: hovered ? SatoriColors.textDark : item.color, letterSpacing: -0.6),
          child: Text(item.label),
        ),
        const SizedBox(height: 5),
        Text(item.detail, style: TextStyle(fontSize: 14,
            color: SatoriColors.textMid.withAlpha(210), fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _SmallContent extends StatelessWidget {
  final _NavItem item;
  final bool hovered;
  const _SmallContent({required this.item, required this.hovered});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: item.color, borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: item.color.withAlpha(hovered ? 130 : 70),
                  blurRadius: hovered ? 14 : 8, offset: Offset(0, hovered ? 6 : 3))],
              ),
              child: Center(child: Text(item.emoji, style: const TextStyle(fontSize: 24))),
            ),
            if (hovered)
              Icon(Icons.arrow_forward_ios_rounded, size: 13,
                  color: item.color.withAlpha(170)),
          ],
        ),
        const Spacer(),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 160),
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800,
              color: hovered ? SatoriColors.textDark : item.color, letterSpacing: -0.3),
          maxLines: 2, overflow: TextOverflow.ellipsis,
          child: Text(item.label),
        ),
        const SizedBox(height: 4),
        Text(item.sub, style: const TextStyle(fontSize: 12,
            color: SatoriColors.textMid, fontWeight: FontWeight.w500),
            maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}