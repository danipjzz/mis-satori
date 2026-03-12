import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../widgets/bounce.dart';

// ─── DATOS ────────────────────────────────────────────────────────────────────
const _ventasSemana = [
  {'dia': 'Lun', 'real': 1200.0, 'pred': 1150.0},
  {'dia': 'Mar', 'real': 950.0,  'pred': 1000.0},
  {'dia': 'Mié', 'real': 1800.0, 'pred': 1600.0},
  {'dia': 'Jue', 'real': 1400.0, 'pred': 1350.0},
  {'dia': 'Vie', 'real': 2200.0, 'pred': 2000.0},
  {'dia': 'Sáb', 'real': 3100.0, 'pred': 2800.0},
  {'dia': 'Dom', 'real': 0.0,    'pred': 2400.0, 'futuro': true},
];

const _topProductos = [
  {'nombre': 'Pastel Tres Leches', 'ventas': 28, 'monto': 10080, 'pct': 0.92, 'emoji': '🥛', 'up': true},
  {'nombre': 'Cupcake Fresa',       'ventas': 64, 'monto': 2560,  'pct': 0.78, 'emoji': '🍓', 'up': true},
  {'nombre': 'Pastel Red Velvet',  'ventas': 19, 'monto': 7980,  'pct': 0.65, 'emoji': '❤️', 'up': null},
  {'nombre': 'Pay de Queso',        'ventas': 22, 'monto': 5500,  'pct': 0.55, 'emoji': '🧀', 'up': false},
  {'nombre': 'Galleta Decorada',    'ventas': 87, 'monto': 3045,  'pct': 0.48, 'emoji': '🌸', 'up': true},
];

const _alertas = [
  {'tipo': 'warning', 'msg': 'Sábado: demanda estimada +35% vs semana pasada', 'emoji': '⚡'},
  {'tipo': 'info',    'msg': 'Temporada alta: 15 Jun – 10 Jul (vacaciones)',   'emoji': '📅'},
  {'tipo': 'success', 'msg': 'Meta semanal alcazanda al 82%, ¡excelente ritmo!', 'emoji': '🎯'},
];

const _proyeccion = [
  {'dia': 'Lun', 'est': 1300},
  {'dia': 'Mar', 'est': 1100},
  {'dia': 'Mié', 'est': 1750},
  {'dia': 'Jue', 'est': 1500},
  {'dia': 'Vie', 'est': 2400},
  {'dia': 'Sáb', 'est': 3200},
  {'dia': 'Dom', 'est': 2600},
];

class PrediccionScreen extends StatefulWidget {
  const PrediccionScreen({super.key});
  @override
  State<PrediccionScreen> createState() => _PrediccionScreenState();
}

class _PrediccionScreenState extends State<PrediccionScreen> {
  String _periodo = 'Semana';

  double get _totalReal  => _ventasSemana.where((d) => (d['real'] as double) > 0).fold(0, (a, d) => a + (d['real'] as double));
  double get _totalPred  => _ventasSemana.fold(0, (a, d) => a + (d['pred'] as double));
  int    get _accuracy   => (100 - ((_totalReal - _totalPred).abs() / _totalPred * 100)).round();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SatoriColors.yellowLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header Premium
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  SatoriBounce(
                    onTap: () => context.go('/'),
                    child: Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: const Center(child: Text('‹', style: TextStyle(fontSize: 26, color: Color(0xFFB8860B), fontWeight: FontWeight.w500))),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: ShaderMask(
                        shaderCallback: (b) => const LinearGradient(
                          colors: [Color(0xFFB8860B), SatoriColors.pinkDeep],
                        ).createShader(b),
                        child: Text(
                          'Predicción',
                          style: GoogleFonts.cormorantGaramond(
                                fontSize: 32, fontWeight: FontWeight.w900,
                                fontStyle: FontStyle.italic, color: Colors.white,
                                letterSpacing: -1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 42),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: ['Semana', 'Mes', '3 Meses'].map((p) {
                          final active = _periodo == p;
                          return Expanded(
                            child: SatoriBounce(
                              onTap: () => setState(() => _periodo = p),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: active ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: active ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))] : [],
                                ),
                                child: Center(
                                  child: Text(p, style: TextStyle(fontSize: 14, fontWeight: active ? FontWeight.w800 : FontWeight.w600, color: active ? SatoriColors.textDark : SatoriColors.textMid)),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // KPI Cards
                    Row(
                      children: [
                        _KpiCard('💰', '\$${_totalReal.toInt()}', 'Ventas reales', Colors.white, SatoriColors.teal),
                        const SizedBox(width: 12),
                        _KpiCard('🔮', '\$${_totalPred.toInt()}', 'Predicción', Colors.white, SatoriColors.pinkPrimary),
                        const SizedBox(width: 12),
                        _KpiCard('🎯', '$_accuracy%', 'Precisión', Colors.white, const Color(0xFFB8860B)),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Gráfica
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Ingresos semanales', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: SatoriColors.textDark, letterSpacing: -0.3)),
                                  Row(children: [
                                    _Legend(SatoriColors.pinkPrimary, 'Real'),
                                    const SizedBox(width: 12),
                                    _Legend(SatoriColors.pinkLight, 'Pred.'),
                                  ]),
                                ],
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                height: 180,
                                child: BarChart(
                                  BarChartData(
                                    maxY: 3600,
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      horizontalInterval: 1200,
                                      getDrawingHorizontalLine: (_) => FlLine(color: SatoriColors.pinkPale, strokeWidth: 1.5, dashArray: [4, 4]),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    titlesData: FlTitlesData(
                                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (val, _) {
                                            final i = val.toInt();
                                            if (i < 0 || i >= _ventasSemana.length) return const SizedBox();
                                            final isFuture = _ventasSemana[i]['futuro'] == true;
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 8),
                                              child: Text(
                                                _ventasSemana[i]['dia'] as String,
                                                style: TextStyle(fontSize: 11, fontWeight: isFuture ? FontWeight.w800 : FontWeight.w600, color: isFuture ? SatoriColors.pinkPrimary : SatoriColors.textMid),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    barGroups: List.generate(_ventasSemana.length, (i) {
                                      final d = _ventasSemana[i];
                                      final isFuture = d['futuro'] == true;
                                      return BarChartGroupData(
                                        x: i,
                                        barRods: [
                                          // Background track for projection
                                          BarChartRodData(
                                            toY: 3500,
                                            color: isFuture ? SatoriColors.pinkPale.withOpacity(0.3) : Colors.transparent,
                                            width: 14,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ],
                                        showingTooltipIndicators: [],
                                      );
                                    }).map((bg) {
                                      final i = bg.x;
                                      final d = _ventasSemana[i];
                                      final isFuture = d['futuro'] == true;
                                      return BarChartGroupData(
                                        x: i,
                                        barsSpace: 4,
                                        barRods: [
                                          BarChartRodData(toY: d['pred'] as double, color: SatoriColors.pinkLight, width: 6, borderRadius: BorderRadius.circular(10)),
                                          if (!isFuture)
                                            BarChartRodData(toY: d['real'] as double, color: SatoriColors.pinkPrimary, width: 6, borderRadius: BorderRadius.circular(10)),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    const SizedBox(height: 24),

                    // Top productos
                    const Text('Top Semanal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: SatoriColors.textDark, letterSpacing: -0.4)),
                    const SizedBox(height: 14),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
                      ),
                      child: Column(
                        children: List.generate(_topProductos.length, (i) {
                              final p = _topProductos[i];
                              final upVal = p['up'];
                              final tendColor = upVal == true ? SatoriColors.teal : upVal == false ? SatoriColors.pinkDeep : SatoriColors.textMid;
                              final tendEmoji = upVal == true ? '↗' : upVal == false ? '↘' : '→';
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: i < _topProductos.length - 1 ? SatoriColors.pinkPale : Colors.transparent, width: 0.5))),
                                child: Row(
                                  children: [
                                    Text('${i+1}', style: GoogleFonts.cormorantGaramond(fontSize: 18, fontWeight: FontWeight.w700, fontStyle: FontStyle.italic, color: SatoriColors.pinkPrimary)),
                                    const SizedBox(width: 14),
                                    Text(p['emoji'] as String, style: const TextStyle(fontSize: 24)),
                                    const SizedBox(width: 16),
                                    Expanded(child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          Expanded(child: Text(p['nombre'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: SatoriColors.textDark))),
                                          Text(tendEmoji, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: tendColor)),
                                        ]),
                                        const SizedBox(height: 2),
                                        Text('${p['ventas']} uds · \$${(p['monto'] as int).toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}',
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: SatoriColors.textMid)),
                                        const SizedBox(height: 8),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: p['pct'] as double,
                                            backgroundColor: SatoriColors.pinkPale.withOpacity(0.5),
                                            valueColor: AlwaysStoppedAnimation(i == 0 ? SatoriColors.tealLight : SatoriColors.pinkPrimary.withOpacity(0.6)),
                                            minHeight: 4,
                                          ),
                                        ),
                                      ],
                                    )),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),

                    const SizedBox(height: 24),

                    // Proyección
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: SatoriColors.tealPale.withOpacity(0.4), borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: SatoriColors.tealLight.withOpacity(0.3), width: 1.5),
                        boxShadow: [BoxShadow(color: SatoriColors.teal.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Proyección próxima semana', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: SatoriColors.tealDark, letterSpacing: -0.2)),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: _proyeccion.map((d) => Column(children: [
                              Text(d['dia'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: SatoriColors.teal)),
                              const SizedBox(height: 6),
                              Text('\$${((d['est'] as int) / 1000).toStringAsFixed(1)}k', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: SatoriColors.tealDark)),
                            ])).toList(),
                          ),
                          const SizedBox(height: 16),
                          Divider(color: SatoriColors.tealLight.withOpacity(0.5)),
                          const SizedBox(height: 8),
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            const Text('Cierre estimado al domingo: ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SatoriColors.tealDark)),
                            const Text('\$13,850', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: SatoriColors.tealDark)),
                          ]),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Alertas minimalistas
                    const Text('Inteligencia', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: SatoriColors.textDark, letterSpacing: -0.4)),
                    const SizedBox(height: 12),
                    ..._alertas.map((a) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white, borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a['emoji'] as String, style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 12),
                            Expanded(child: Text(a['msg'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SatoriColors.textDark, height: 1.4))),
                          ],
                        ),
                      );
                    }),
                    
                    const SizedBox(height: 12),
                    
                    // Call to Action
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB8860B),
                          foregroundColor: Colors.white,
                          elevation: 6,
                          shadowColor: const Color(0xFFB8860B).withAlpha(100),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                        ),
                        child: const Text('Exportar Reporte Mensual', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5)),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String emoji, value, label;
  final Color bg, accent;
  const _KpiCard(this.emoji, this.value, this.label, this.bg, this.accent);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.12),
            blurRadius: 16, offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Column(children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: SatoriColors.textDark), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: SatoriColors.textMid), textAlign: TextAlign.center),
          ]),
        ),
      ),
    ),
  );
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend(this.color, this.label);

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 6),
    Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: SatoriColors.textMid)),
  ]);
}

