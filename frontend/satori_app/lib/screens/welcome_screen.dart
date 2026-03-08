// lib/screens/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/colors.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeHeader;
  late Animation<Offset> _slideHeader;
  final List<Animation<double>> _cardFades = [];
  final List<Animation<Offset>> _cardSlides = [];

  static const _items = [
    _NavItem('Pedidos',    '📅', 'Calendario & órdenes',    SatoriColors.teal,        SatoriColors.tealPale,   SatoriColors.tealLight,  '/pedidos'),
    _NavItem('Venta',      '🧾', 'Cobros & productos',      SatoriColors.pinkPrimary, SatoriColors.pinkPale,   SatoriColors.pinkLight,  '/venta'),
    _NavItem('Predicción', '📈', 'Tendencias de ventas',    SatoriColors.yellow,      Color(0xFFFFF3CC),       Color(0xFFFFE89A),       '/prediccion'),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

    _fadeHeader  = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)));
    _slideHeader = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)));

    for (int i = 0; i < _items.length; i++) {
      final start = 0.3 + i * 0.15;
      final end   = start + 0.35;
      _cardFades.add(Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Interval(start, end.clamp(0, 1), curve: Curves.easeOut))));
      _cardSlides.add(Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Interval(start, end.clamp(0, 1), curve: Curves.easeOut))));
    }

    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SatoriColors.pinkPale,
      body: Stack(
        children: [
          // Blobs decorativos
          Positioned(top: -60, right: -60, child: _Blob(200, SatoriColors.tealPale, 0.6)),
          Positioned(bottom: -80, left: -40, child: _Blob(240, SatoriColors.pinkLight, 0.7)),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Header animado
                  FadeTransition(
                    opacity: _fadeHeader,
                    child: SlideTransition(
                      position: _slideHeader,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Logo
                          Row(
                            children: [
                              const Text('🐱', style: TextStyle(fontSize: 44)),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Satori', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: SatoriColors.teal, letterSpacing: -0.5)),
                                  const Text('Gestión de pastelería', style: TextStyle(fontSize: 12, color: SatoriColors.textMid)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Saludo
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                            decoration: BoxDecoration(
                              color: SatoriColors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('¡Hola, bienvenida! 👋', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: SatoriColors.textDark)),
                                SizedBox(height: 2),
                                Text('¿Qué hacemos hoy?', style: TextStyle(fontSize: 14, color: SatoriColors.textMid)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Cards
                  Expanded(
                    child: Column(
                      children: List.generate(_items.length, (i) {
                        final item = _items[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: FadeTransition(
                            opacity: _cardFades[i],
                            child: SlideTransition(
                              position: _cardSlides[i],
                              child: _NavCard(item: item),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // Footer
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Text('🍰 Satori © 2025', style: TextStyle(color: SatoriColors.textLight, fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final String label, emoji, sub, route;
  final Color color, colorLight, shadow;
  const _NavItem(this.label, this.emoji, this.sub, this.color, this.colorLight, this.shadow, this.route);
}

class _NavCard extends StatelessWidget {
  final _NavItem item;
  const _NavCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(item.route),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
        decoration: BoxDecoration(
          color: item.colorLight,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: item.color, width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 14, offset: const Offset(0, 6))],
        ),
        child: Row(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(color: item.color, shape: BoxShape.circle),
              child: Center(child: Text(item.emoji, style: const TextStyle(fontSize: 26))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: item.color)),
                  const SizedBox(height: 2),
                  Text(item.sub, style: const TextStyle(fontSize: 13, color: SatoriColors.textMid)),
                ],
              ),
            ),
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: item.color, shape: BoxShape.circle),
              child: const Center(child: Text('›', style: TextStyle(color: SatoriColors.white, fontSize: 22, fontWeight: FontWeight.w700))),
            ),
          ],
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;
  const _Blob(this.size, this.color, this.opacity);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
