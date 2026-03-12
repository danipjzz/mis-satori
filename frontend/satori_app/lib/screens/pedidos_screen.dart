// lib/screens/pedidos_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../widgets/bounce.dart';

// ─── MODELOS ─────────────────────────────────────────────────────────────────
class Pedido {
  final String id, cliente, producto, hora, estado, monto, nota;
  const Pedido({required this.id, required this.cliente, required this.producto,
    required this.hora, required this.estado, required this.monto, this.nota = ''});
}

// Initial data
final Map<DateTime, List<Pedido>> _initialPedidos = {
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
  bool _showAddModal = false;
  late Map<DateTime, List<Pedido>> _pedidos;

  @override
  void initState() {
    super.initState();
    _pedidos = Map.from(_initialPedidos);
  }

  List<Pedido> get _pedidosDelDia => _pedidos[_dayKey(_selected)] ?? [];

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
                      Expanded(
                        child: Center(
                          child: ShaderMask(
                            shaderCallback: (b) => const LinearGradient(
                              colors: [SatoriColors.tealDark, SatoriColors.textDark],
                            ).createShader(b),
                            child: Text(
                              'Pedidos',
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 28, fontWeight: FontWeight.w900,
                                fontStyle: FontStyle.italic, color: Colors.white,
                                letterSpacing: -1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      _CircleBtn(
                        icon: '+', 
                        color: SatoriColors.teal, 
                        bg: SatoriColors.teal, 
                        textColor: SatoriColors.white, 
                        onTap: () => setState(() => _showAddModal = true),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
                          ),
                          child: TableCalendar<Pedido>(
                                firstDay: DateTime(2024),
                                lastDay: DateTime(2027),
                                focusedDay: _focused,
                                selectedDayPredicate: (d) => isSameDay(d, _selected),
                                eventLoader: (d) => _pedidos[_dayKey(d)] ?? [],
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
                          _EmptyState(onAdd: () => setState(() => _showAddModal = true))
                        else
                          ..._pedidosDelDia.map((p) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _PedidoCard(pedido: p, onTap: () => setState(() => _modalPedido = p)),
                          )),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Modal Detalle
          if (_modalPedido != null)
            _PedidoModal(pedido: _modalPedido!, onClose: () => setState(() => _modalPedido = null)),

          // Modal Agregar
          if (_showAddModal)
            _AddPedidoModal(
              onClose: () => setState(() => _showAddModal = false),
              onAdd: (p) => setState(() {
                final day = _dayKey(_selected);
                _pedidos[day] = [...(_pedidos[day] ?? []), p];
                _showAddModal = false;
              }),
            ),
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
    return SatoriBounce(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: st['dot'].withOpacity(0.08),
              blurRadius: 15, offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(width: 5, height: 90, decoration: BoxDecoration(color: st['dot'], borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), bottomLeft: Radius.circular(24)))),
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
        color: Colors.black.withOpacity(0.4),
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: SingleChildScrollView(
              child: Margin(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: SatoriColors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20)]),
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
                      SatoriBounce(
                        onTap: onClose,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: SatoriColors.teal,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: SatoriColors.teal.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                          ),
                          child: const Center(
                            child: Text('Cerrar', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 0.5, color: Colors.white)),
                          ),
                        ),
                      ),
                    ],
                  ),
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
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Column(
      children: [
        const Text('🍰', style: TextStyle(fontSize: 56)),
        const SizedBox(height: 12),
        const Text('Sin pedidos este día', style: TextStyle(fontSize: 16, color: SatoriColors.textMid)),
        const SizedBox(height: 20),
        SatoriBounce(
          onTap: onAdd,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            decoration: BoxDecoration(
              color: SatoriColors.pinkPrimary,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: SatoriColors.pinkDeep.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: const Text('+ Agregar pedido', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 0.5, color: Colors.white)),
          ),
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
  Widget build(BuildContext context) => SatoriBounce(
    onTap: onTap,
    child: Container(
      width: 38, height: 38,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 2))]),
      child: Center(child: Text(icon, style: TextStyle(fontSize: 22, color: textColor, fontWeight: FontWeight.w700))),
    ),
  );
}

class _AddPedidoModal extends StatefulWidget {
  final VoidCallback onClose;
  final Function(Pedido) onAdd;
  const _AddPedidoModal({required this.onClose, required this.onAdd});

  @override
  State<_AddPedidoModal> createState() => _AddPedidoModalState();
}

class _AddPedidoModalState extends State<_AddPedidoModal> {
  final _nombre = TextEditingController();
  final _direccion = TextEditingController();
  final _telefono = TextEditingController();
  final _monto = TextEditingController();
  final _postre = TextEditingController();

  String? _nombreErr, _montoErr, _postreErr;

  void _confirmar() {
    setState(() {
      _nombreErr = _nombre.text.isEmpty ? 'El nombre es obligatorio' : null;
      _montoErr = _monto.text.isEmpty ? 'El monto es obligatorio' : null;
      _postreErr = _postre.text.isEmpty ? 'El postre es obligatorio' : null;
    });

    if (_nombreErr == null && _montoErr == null && _postreErr == null) {
      widget.onAdd(Pedido(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        cliente: _nombre.text,
        producto: _postre.text,
        hora: 'Pendiente',
        estado: 'pendiente',
        monto: '\$${_monto.text}',
        nota: [
          if (_direccion.text.isNotEmpty) 'Entrega: ${_direccion.text}',
          if (_telefono.text.isNotEmpty) 'Tel: ${_telefono.text}',
        ].join(' · '),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        color: Colors.black.withOpacity(0.4),
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: SingleChildScrollView(
              child: Margin(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: SatoriColors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20)]),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nuevo Pedido', style: GoogleFonts.cormorantGaramond(fontSize: 28, fontWeight: FontWeight.w800, fontStyle: FontStyle.italic, color: SatoriColors.tealDark)),
                      const SizedBox(height: 16),
                      _field('Nombre del cliente *', _nombre, 'Ej: María López', error: _nombreErr),
                      _field('Dirección de entrega', _direccion, 'Ej: Av. Principal 123'),
                      _field('Teléfono', _telefono, 'Ej: 321 456 7890', keyboard: TextInputType.phone),
                      _field('Monto a cobrar *', _monto, 'Ej: 450', prefix: '\$ ', keyboard: TextInputType.number, error: _montoErr),
                      _field('¿Qué postre? *', _postre, 'Ej: Pastel de tres leches', error: _postreErr),
                      const SizedBox(height: 24),
                      SatoriBounce(
                        onTap: _confirmar,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            color: SatoriColors.teal,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: SatoriColors.teal.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                          ),
                          child: const Center(
                            child: Text('Confirmar Pedido', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 0.5, color: Colors.white)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, String hint, {TextInputType? keyboard, String? prefix, String? error}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: SatoriColors.textMid)),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl,
            keyboardType: keyboard,
            style: const TextStyle(fontSize: 14, color: SatoriColors.textDark),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: SatoriColors.textLight.withOpacity(0.6), fontSize: 14),
              prefixText: prefix,
              errorText: error,
              errorStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: SatoriColors.pinkPrimary),
              filled: true,
              fillColor: SatoriColors.tealPale.withOpacity(0.3),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: SatoriColors.teal, width: 1.5)),
              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: SatoriColors.pinkPrimary, width: 1.2)),
              focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: SatoriColors.pinkPrimary, width: 2.0)),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper para margin en modal
class Margin extends StatelessWidget {
  final EdgeInsets margin;
  final Widget child;
  const Margin({super.key, required this.margin, required this.child});
  @override
  Widget build(BuildContext context) => Padding(padding: margin, child: child);
}
