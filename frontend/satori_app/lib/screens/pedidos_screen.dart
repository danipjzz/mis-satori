// lib/screens/pedidos_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../theme/colors.dart';

// ─── MODELOS ─────────────────────────────────────────────────────────────────
class Pedido {
  final String id, cliente, producto, hora, estado, monto, nota;
  const Pedido({required this.id, required this.cliente, required this.producto,
    required this.hora, required this.estado, required this.monto, this.nota = ''});
}

// ─── DATOS DE EJEMPLO ─────────────────────────────────────────────────────────
final Map<DateTime, List<Pedido>> _pedidosData = {
  DateTime(2025, 6, 7): [
    const Pedido(id:'1', cliente:'María López',  producto:'Pastel 3 pisos',  hora:'10:00 AM', estado:'pendiente', monto:'\$450',  nota:'Flores rosas, mensaje "Feliz Cumple"'),
    const Pedido(id:'2', cliente:'Juan García',  producto:'Cupcakes x12',    hora:'01:00 PM', estado:'listo',     monto:'\$180',  nota:'Sabor vainilla con betún azul'),
    const Pedido(id:'3', cliente:'Ana Ramos',    producto:'Pay de queso',    hora:'04:00 PM', estado:'pendiente', monto:'\$220'),
  ],
  DateTime(2025, 6, 8): [
    const Pedido(id:'4', cliente:'Pedro Ríos',   producto:'Pastel Chocolate',hora:'11:00 AM', estado:'pendiente', monto:'\$380',  nota:'Sin nueces'),
    const Pedido(id:'5', cliente:'Laura Torres', producto:'Galletas x24',    hora:'03:00 PM', estado:'entregado', monto:'\$150',  nota:'Figuras de animales'),
  ],
  DateTime(2025, 6, 12): [
    const Pedido(id:'6', cliente:'Carlos Vega',  producto:'Pastel Quince',   hora:'10:00 AM', estado:'pendiente', monto:'\$1,200', nota:'5 pisos, temática rosa gold'),
  ],
};

DateTime _dayKey(DateTime d) => DateTime(d.year, d.month, d.day);

// ─── STATUS CONFIG ────────────────────────────────────────────────────────────
Map<String, dynamic> statusConfig(String estado) {
  switch (estado) {
    case 'listo':     return {'label':'Listo',     'bg': const Color(0xFFE8F8E8), 'text': SatoriColors.greenDark, 'dot': SatoriColors.green};
    case 'entregado': return {'label':'Entregado', 'bg': SatoriColors.tealPale,   'text': SatoriColors.tealDark,  'dot': SatoriColors.teal};
    default:          return {'label':'Pendiente', 'bg': SatoriColors.yellowLight,'text': const Color(0xFFB8860B),'dot': SatoriColors.yellow};
  }
}

// ─── SCREEN ──────────────────────────────────────────────────────────────────
class PedidosScreen extends StatefulWidget {
  const PedidosScreen({super.key});
  @override
  State<PedidosScreen> createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen> {
  DateTime _focused = DateTime.now();
  DateTime _selected = _dayKey(DateTime.now());
  Pedido? _modalPedido;

  List<Pedido> get _pedidosDelDia => _pedidosData[_dayKey(_selected)] ?? [];

  int get _totalDia => _pedidosDelDia.fold(0, (acc, p) {
    final clean = p.monto.replaceAll(RegExp(r'[^\d]'), '');
    return acc + (int.tryParse(clean) ?? 0);
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SatoriColors.tealPale,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      _CircleBtn(
                        icon: '‹',
                        color: SatoriColors.teal,
                        onTap: () => context.go('/'),
                      ),
                      const Expanded(child: Center(child: Text('📅 Pedidos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: SatoriColors.textDark)))),
                      _CircleBtn(icon: '+', color: SatoriColors.teal, bg: SatoriColors.teal, textColor: SatoriColors.white, onTap: () {}),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // Calendario
                        Container(
                          decoration: BoxDecoration(
                            color: SatoriColors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
                          ),
                          child: TableCalendar<Pedido>(
                            firstDay: DateTime(2024),
                            lastDay: DateTime(2027),
                            focusedDay: _focused,
                            selectedDayPredicate: (d) => isSameDay(d, _selected),
                            eventLoader: (d) => _pedidosData[_dayKey(d)] ?? [],
                            onDaySelected: (sel, foc) => setState(() { _selected = sel; _focused = foc; }),
                            onPageChanged: (foc) => setState(() => _focused = foc),
                            calendarStyle: CalendarStyle(
                              selectedDecoration: const BoxDecoration(color: SatoriColors.teal, shape: BoxShape.circle),
                              todayDecoration: BoxDecoration(color: SatoriColors.tealLight, shape: BoxShape.circle),
                              todayTextStyle: const TextStyle(color: SatoriColors.tealDark, fontWeight: FontWeight.w700),
                              selectedTextStyle: const TextStyle(color: SatoriColors.white, fontWeight: FontWeight.w700),
                              markerDecoration: const BoxDecoration(color: SatoriColors.pinkPrimary, shape: BoxShape.circle),
                              markerSize: 5,
                            ),
                            headerStyle: const HeaderStyle(
                              formatButtonVisible: false,
                              titleCentered: true,
                              titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: SatoriColors.textDark),
                              leftChevronIcon: Icon(Icons.chevron_left, color: SatoriColors.teal),
                              rightChevronIcon: Icon(Icons.chevron_right, color: SatoriColors.teal),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Resumen del día
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatDate(_selected),
                                  style: const TextStyle(fontSize: 13, color: SatoriColors.textMid),
                                ),
                                Text(
                                  '${_pedidosDelDia.length} pedido${_pedidosDelDia.length != 1 ? "s" : ""}',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: SatoriColors.textDark),
                                ),
                              ],
                            ),
                            if (_pedidosDelDia.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                decoration: BoxDecoration(color: SatoriColors.teal, borderRadius: BorderRadius.circular(14)),
                                child: Column(
                                  children: [
                                    const Text('Total día', style: TextStyle(fontSize: 11, color: Colors.white70)),
                                    Text('\$$_totalDia', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: SatoriColors.white)),
                                  ],
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Lista pedidos
                        if (_pedidosDelDia.isEmpty)
                          _EmptyState()
                        else
                          ...(_pedidosDelDia.map((p) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _PedidoCard(pedido: p, onTap: () => setState(() => _modalPedido = p)),
                          ))),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Modal
          if (_modalPedido != null)
            _PedidoModal(pedido: _modalPedido!, onClose: () => setState(() => _modalPedido = null)),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    const meses = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
    const dias  = ['Domingo','Lunes','Martes','Miércoles','Jueves','Viernes','Sábado'];
    return '${dias[d.weekday % 7]}, ${d.day} ${meses[d.month - 1]} ${d.year}';
  }
}

// ─── WIDGETS ─────────────────────────────────────────────────────────────────
class _PedidoCard extends StatelessWidget {
  final Pedido pedido;
  final VoidCallback onTap;
  const _PedidoCard({required this.pedido, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final st = statusConfig(pedido.estado);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: SatoriColors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(width: 5, height: 90, decoration: BoxDecoration(color: st['dot'], borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), bottomLeft: Radius.circular(18)))),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(pedido.cliente, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: SatoriColors.textDark))),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                          decoration: BoxDecoration(color: st['bg'], borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            children: [
                              Container(width: 6, height: 6, decoration: BoxDecoration(color: st['dot'], shape: BoxShape.circle)),
                              const SizedBox(width: 4),
                              Text(st['label'], style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: st['text'])),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(pedido.producto, style: const TextStyle(fontSize: 13, color: SatoriColors.textMid)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('🕐', style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 4),
                        Text(pedido.hora, style: const TextStyle(fontSize: 13, color: SatoriColors.textMid)),
                        const SizedBox(width: 16),
                        const Text('💰', style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 4),
                        Text(pedido.monto, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: SatoriColors.tealDark)),
                      ],
                    ),
                    if (pedido.nota.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: SatoriColors.yellowLight, borderRadius: BorderRadius.circular(8)),
                        child: Text('📝 ${pedido.nota}', style: const TextStyle(fontSize: 12, color: Color(0xFF8B6914))),
                      ),
                    ],
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

class _PedidoModal extends StatelessWidget {
  final Pedido pedido;
  final VoidCallback onClose;
  const _PedidoModal({required this.pedido, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final st = statusConfig(pedido.estado);
    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Margin(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: SatoriColors.white, borderRadius: BorderRadius.circular(24)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pedido.producto, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: SatoriColors.textDark)),
                    const SizedBox(height: 4),
                    Text('👤 ${pedido.cliente}', style: const TextStyle(fontSize: 15, color: SatoriColors.textMid)),
                    const SizedBox(height: 16),
                    _ModalRow('🕐 Hora:', pedido.hora),
                    _ModalRow('💰 Monto:', pedido.monto, valueColor: SatoriColors.tealDark, bold: true),
                    _ModalRow('Estado:', st['label']),
                    if (pedido.nota.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: SatoriColors.yellowLight, borderRadius: BorderRadius.circular(10)),
                        child: Text('📝 ${pedido.nota}', style: const TextStyle(fontSize: 13, color: Color(0xFF8B6914))),
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onClose,
                        style: ElevatedButton.styleFrom(backgroundColor: SatoriColors.teal, foregroundColor: SatoriColors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), padding: const EdgeInsets.symmetric(vertical: 14)),
                        child: const Text('Cerrar', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModalRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  final bool bold;
  const _ModalRow(this.label, this.value, {this.valueColor, this.bold = false});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: SatoriColors.textMid)),
        Text(value, style: TextStyle(fontSize: 14, color: valueColor ?? SatoriColors.textDark, fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
      ],
    ),
  );
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Column(
      children: [
        const Text('🍰', style: TextStyle(fontSize: 56)),
        const SizedBox(height: 12),
        const Text('Sin pedidos este día', style: TextStyle(fontSize: 16, color: SatoriColors.textMid)),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(backgroundColor: SatoriColors.teal, foregroundColor: SatoriColors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 28)),
          child: const Text('+ Agregar pedido', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        ),
      ],
    ),
  );
}

class _CircleBtn extends StatelessWidget {
  final String icon;
  final Color color;
  final Color bg;
  final Color textColor;
  final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.color, this.bg = SatoriColors.white, this.textColor = SatoriColors.teal, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 38, height: 38,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 2))]),
      child: Center(child: Text(icon, style: TextStyle(fontSize: 22, color: textColor, fontWeight: FontWeight.w700))),
    ),
  );
}

// Helper para margin en modal
class Margin extends StatelessWidget {
  final EdgeInsets margin;
  final Widget child;
  const Margin({super.key, required this.margin, required this.child});
  @override
  Widget build(BuildContext context) => Padding(padding: margin, child: child);
}
