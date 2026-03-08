// lib/main.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'theme/colors.dart';
import 'screens/welcome_screen.dart';
import 'screens/pedidos_screen.dart';
import 'screens/venta_screen.dart';
import 'screens/prediccion_screen.dart';

void main() {
  runApp(const SatoriApp());
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/',          builder: (_, __) => const WelcomeScreen()),
    GoRoute(path: '/pedidos',   builder: (_, __) => const PedidosScreen()),
    GoRoute(path: '/venta',     builder: (_, __) => const VentaScreen()),
    GoRoute(path: '/prediccion',builder: (_, __) => const PrediccionScreen()),
  ],
);

class SatoriApp extends StatelessWidget {
  const SatoriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Satori',
      debugShowCheckedModeBanner: false,
      theme: SatoriTheme.theme,
      routerConfig: _router,
    );
  }
}
