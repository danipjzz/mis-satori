// lib/screens/prediccion_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/colors.dart';

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
  {'tipo': 'success', 'msg': 'Meta semanal: 82% alcanzada, ¡vas muy bien!',   'emoji': '🎯'},
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
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/'),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(color: SatoriColors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6)]),
                      child: const Center(child: Text('‹', style: TextStyle(fontSize: 22, color: Color(0xFFB8860B), fontWeight: FontWeight.w700))),
                    ),
                  ),
                  const Expanded(child: Center(child: Text('📈 Predicción', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: SatoriColors.textDark)))),
                  const SizedBox(width: 38),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Selector período
                    Container(
                      decoration: BoxDecoration(color: SatoriColors.white, borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: ['Semana', 'Mes', '3 Meses'].map((p) {
                          final active = _periodo == p;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _periodo = p),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 9),
                                decoration: BoxDecoration(color: active ? SatoriColors.yellow : Colors.transparent, borderRadius: BorderRadius.circular(10)),
                                child: Center(child: Text(p, style: TextStyle(fontSize: 13, fontWeight: active ? FontWeight.w800 : FontWeight.w600, color: active ? SatoriColors.textDark : SatoriColors.textMid))),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // KPI Cards
                    Row(
                      children: [
                        _KpiCard('💰', '\$${_totalReal.toInt()}', 'Ventas reales', SatoriColors.tealPale, SatoriColors.tealLight),
                        const SizedBox(width: 10),
                        _KpiCard('🔮', '\$${_totalPred.toInt()}', 'Predicción',   SatoriColors.pinkPale, SatoriColors.pinkLight),
                        const SizedBox(width: 10),
                        _KpiCard('🎯', '$_accuracy%',             'Precisión',    SatoriColors.yellowLight, const Color(0xFFFFE099)),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Gráfica
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(color: SatoriColors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 10)]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Ventas por día', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: SatoriColors.textDark)),
                              Row(children: [
                                _Legend(SatoriColors.teal, 'Real'),
                                const SizedBox(width: 12),
                                _Legend(SatoriColors.tealLight, 'Predicción'),
                              ]),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 160,
                            child: BarChart(
                              BarChartData(
                                maxY: 3500,
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  horizontalInterval: 1000,
                                  getDrawingHorizontalLine: (_) => FlLine(color: SatoriColors.pinkPale, strokeWidth: 1),
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
                                        return Text(
                                          _ventasSemana[i]['dia'] as String,
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isFuture ? SatoriColors.teal : SatoriColors.textMid),
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
                                      BarChartRodData(toY: d['pred'] as double, color: SatoriColors.tealLight, width: 12, borderRadius: BorderRadius.circular(4)),
                                      if (!isFuture)
                                        BarChartRodData(toY: d['real'] as double, color: SatoriColors.teal, width: 12, borderRadius: BorderRadius.circular(4)),
                                    ],
                                    barsSpace: 4,
                                  );
                                }),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Center(child: Text('📌 Domingo: estimado con modelo de tendencia', style: TextStyle(fontSize: 11, color: SatoriColors.textLight))),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Top productos
                    const Text('🏆 Top productos de la semana', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: SatoriColors.textDark)),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(color: SatoriColors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 10)]),
                      child: Column(
                        children: List.generate(_topProductos.length, (i) {
                          final p = _topProductos[i];
                          final upVal = p['up'];
                          final tendColor = upVal == true ? SatoriColors.greenDark : upVal == false ? SatoriColors.pinkDeep : SatoriColors.textMid;
                          final tendEmoji = upVal == true ? '↑' : upVal == false ? '↓' : '→';
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: i < _topProductos.length - 1 ? SatoriColors.pinkPale : Colors.transparent))),
                            child: Row(
                              children: [
                                Container(
                                  width: 24, height: 24,
                                  decoration: const BoxDecoration(color: SatoriColors.pinkLight, shape: BoxShape.circle),
                                  child: Center(child: Text('${i+1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: SatoriColors.pinkDeep))),
                                ),
                                const SizedBox(width: 8),
                                Text(p['emoji'] as String, style: const TextStyle(fontSize: 24)),
                                const SizedBox(width: 10),
                                Expanded(child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Expanded(child: Text(p['nombre'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: SatoriColors.textDark))),
                                      Text(tendEmoji, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: tendColor)),
                                    ]),
                                    Text('${p['ventas']} uds · \$${(p['monto'] as int).toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}',
                                        style: const TextStyle(fontSize: 11, color: SatoriColors.textMid)),
                                    const SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(3),
                                      child: LinearProgressIndicator(
                                        value: p['pct'] as double,
                                        backgroundColor: SatoriColors.pinkPale,
                                        valueColor: AlwaysStoppedAnimation(i == 0 ? SatoriColors.teal : SatoriColors.pinkPrimary),
                                        minHeight: 5,
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

                    const SizedBox(height: 20),

                    // Proyección
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(color: SatoriColors.tealPale, borderRadius: BorderRadius.circular(20), border: Border.all(color: SatoriColors.tealLight, width: 1.5)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('🔮 Proyección próxima semana', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: SatoriColors.tealDark)),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: _proyeccion.map((d) => Column(children: [
                              Text(d['dia'] as String, style: const TextStyle(fontSize: 11, color: SatoriColors.textMid)),
                              const SizedBox(height: 4),
                              Text('\$${((d['est'] as int) / 1000).toStringAsFixed(1)}k', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: SatoriColors.tealDark)),
                            ])).toList(),
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: SatoriColors.tealLight),
                          const SizedBox(height: 4),
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            const Text('Total estimado: ', style: TextStyle(fontSize: 14, color: SatoriColors.textMid)),
                            const Text('\$13,850', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: SatoriColors.tealDark)),
                          ]),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Text('⚡ Alertas y recomendaciones', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: SatoriColors.textDark)),
                    const SizedBox(height: 12),

                    ..._alertas.map((a) {
                      Color bg, border;
                      switch (a['tipo']) {
                        case 'warning': bg = SatoriColors.yellowLight; border = SatoriColors.yellow; break;
                        case 'success': bg = const Color(0xFFE8F8E8);  border = SatoriColors.green; break;
                        default:        bg = SatoriColors.tealPale;    border = SatoriColors.tealLight;
                      }
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14), border: Border.all(color: border, width: 1.5)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a['emoji'] as String, style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 10),
                            Expanded(child: Text(a['msg'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SatoriColors.textDark, height: 1.4))),
                          ],
                        ),
                      );
                    }),

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
  final Color bg, border;
  const _KpiCard(this.emoji, this.value, this.label, this.bg, this.border);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16), border: Border.all(color: border, width: 1.5)),
      child: Column(children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: SatoriColors.textDark), textAlign: TextAlign.center),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: SatoriColors.textMid), textAlign: TextAlign.center),
      ]),
    ),
  );
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend(this.color, this.label);

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 5),
    Text(label, style: const TextStyle(fontSize: 11, color: SatoriColors.textMid)),
  ]);
}
