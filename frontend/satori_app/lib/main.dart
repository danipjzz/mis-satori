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
    GoRoute(path: '/',           pageBuilder: (context, state) => _premiumTransition(const WelcomeScreen(), state)),
    GoRoute(path: '/pedidos',    pageBuilder: (context, state) => _premiumTransition(const PedidosScreen(), state)),
    GoRoute(path: '/venta',      pageBuilder: (context, state) => _premiumTransition(const VentaScreen(), state)),
    GoRoute(path: '/prediccion', pageBuilder: (context, state) => _premiumTransition(const PrediccionScreen(), state)),
  ],
);

CustomTransitionPage _premiumTransition(Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.98, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 400),
  );
}

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
