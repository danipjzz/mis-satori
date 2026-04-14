import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../widgets/bounce.dart';
import '../services/api_service.dart';

class Pedido {
  final String id;
  final String cliente;
  final String telefono;
  final String producto;
  final String hora;
  final String estado;
  final String tipoPedido;
  final String tipoTorta;
  final String pesoTorta;
  final String saborPonque;
  final String rellenoBase;
  final String rellenoEspecial;
  final String tipeTortaEspecial;
  final String postres;

  const Pedido({
    required this.id,
    required this.cliente,
    required this.telefono,
    required this.producto,
    required this.hora,
    required this.estado,
    this.tipoPedido = '',
    this.tipoTorta = '',
    this.pesoTorta = '',
    this.saborPonque = '',
    this.rellenoBase = '',
    this.rellenoEspecial = '',
    this.tipeTortaEspecial = '',
    this.postres = '',
  });
}

DateTime _dayKey(DateTime d) => DateTime(d.year, d.month, d.day);

Map<String, dynamic> statusConfig(String estado) {
  switch (estado) {
    case 'entregado':
      return {
        'label': 'Entregado',
        'bg': SatoriColors.tealPale,
        'text': SatoriColors.tealDark,
        'dot': SatoriColors.teal
      };
    default:
      return {
        'label': 'Pendiente',
        'bg': SatoriColors.yellowLight,
        'text': const Color(0xFFB8860B),
        'dot': SatoriColors.yellow
      };
  }
}

class PedidosScreen extends StatefulWidget {
  const PedidosScreen({super.key});

  @override
  State<PedidosScreen> createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen> {
  Map<DateTime, List<Pedido>> _pedidos = {};

  DateTime _focused = DateTime.now();
  DateTime _selected = _dayKey(DateTime.now());

  Pedido? _modalPedido;

  @override
  void initState() {
    super.initState();
    _cargarPedidos();
  }
  String _describirPedido(dynamic p) {
  final tipoPedido  = (p["tipo_pedido"] ?? "").toString().trim();
  final tipoTorta   = (p["tipo_torta"] ?? "").toString().trim();
  final pesoTorta   = (p["peso_torta"] ?? "").toString().trim();
  final saborPonque = (p["sabor_ponque"] ?? "").toString().trim();
  final postres     = (p["postres"] ?? "").toString().trim();

  if (tipoPedido == "Mini postres" && postres.isNotEmpty) return "Mini postres: $postres";
  if (tipoPedido.isNotEmpty) return tipoPedido;
  if (tipoTorta.isNotEmpty) return tipoTorta;
  if (pesoTorta.isNotEmpty && saborPonque.isNotEmpty) return "$pesoTorta · $saborPonque";
  if (pesoTorta.isNotEmpty) return pesoTorta;
  if (saborPonque.isNotEmpty) return saborPonque;

  return "Pedido";
}
  Future<void> _cargarPedidos() async {
  try {
    final data = await ApiService.getPedidos();

    

    Map<DateTime, List<Pedido>> map = {};

    for (var p in data) {

    // 🚫 FILTRO CLAVE
    if (p["estado"]?.toString() == "entregado") continue;

    if (p["fecha_entrega"] == null) continue;

    DateTime fecha;
    try {
      fecha = DateTime.parse(p["fecha_entrega"]).toUtc();
    } catch (_) {
      continue;
    }

      final day = DateTime(fecha.year, fecha.month, fecha.day);

      final pedido = Pedido(
        id: p["id"]?.toString() ?? "0",
        cliente: p["nombre"]?.toString() ?? "Cliente",
        telefono: p["telefono"]?.toString() ?? "",
        producto: _describirPedido(p),
        hora: p["hora_entrega"]?.toString() ?? "",
        estado: p["estado"]?.toString() ?? "pendiente",
        tipoPedido: p["tipo_pedido"]?.toString() ?? "",
        tipoTorta: p["tipo_torta"]?.toString() ?? "",
        pesoTorta: p["peso_torta"]?.toString() ?? "",
        saborPonque: p["sabor_ponque"]?.toString() ?? "",
        rellenoBase: p["relleno_base"]?.toString() ?? "",
        rellenoEspecial: p["relleno_especial"]?.toString() ?? "",
        tipeTortaEspecial: p["tipo_torta_especial"]?.toString() ?? "",
        postres: p["postres"]?.toString() ?? "",
      );

      map.putIfAbsent(day, () => []);
      map[day]!.add(pedido);
    }

    setState(() {
      _pedidos = map;
    });
  } catch (e) {
    print("Error cargando pedidos: $e");
  }
}

  List<Pedido> get _pedidosDelDia => _pedidos[_dayKey(_selected)] ?? [];

  Future<void> _marcarEntregado(Pedido pedido) async {
    try {
      await ApiService.marcarEntregado(pedido.id);
      await _cargarPedidos();
      setState(() {
        _modalPedido = null;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SatoriColors.tealPale,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      _CircleBtn(
                          icon: '‹',
                          color: SatoriColors.teal,
                          onTap: () => context.go('/')),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Pedidos',
                            style: GoogleFonts.cormorantGaramond(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                      ),
                      // ← agrega este botón
                      _CircleBtn(
                          icon: '↻',
                          color: SatoriColors.teal,
                          onTap: _cargarPedidos),
                    ],
                  ),
                ),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24)),
                  child: TableCalendar(
                    firstDay: DateTime(2024),
                    lastDay: DateTime(2030),
                    focusedDay: _focused,
                    selectedDayPredicate: (d) => isSameDay(d, _selected),
                    eventLoader: (d) => _pedidos[_dayKey(d)] ?? [],
                    onDaySelected: (sel, foc) {
                      setState(() {
                        _selected = _dayKey(sel);
                        _focused = foc;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: _pedidosDelDia
                        .map((p) => _PedidoCard(
                            pedido: p,
                            onTap: () =>
                                setState(() => _modalPedido = p)))
                        .toList(),
                  ),
                )
              ],
            ),
          ),

          if (_modalPedido != null)
            _PedidoModal(
                pedido: _modalPedido!,
                onClose: () => setState(() => _modalPedido = null),
                onEntregar: () => _marcarEntregado(_modalPedido!))
        ],
      ),
    );
  }
}

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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(pedido.cliente,
                style:
                    const TextStyle(fontWeight: FontWeight.bold)),
            Text(pedido.producto),
            Text("📞 ${pedido.telefono}"),
            Text("🕐 ${pedido.hora}"),
            Text(st["label"])
          ],
        ),
      ),
    );
  }
}

class _PedidoModal extends StatelessWidget {
  final Pedido pedido;
  final VoidCallback onClose;
  final VoidCallback onEntregar;

  const _PedidoModal({
    required this.pedido,
    required this.onClose,
    required this.onEntregar,
  });

  Widget _fila(String label, String valor) {
    if (valor.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                    fontSize: 13)),
          ),
          Expanded(
            child: Text(valor, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

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
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24)),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(pedido.cliente,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              color: st["bg"],
                              borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            children: [
                              Container(
                                width: 8, height: 8,
                                decoration: BoxDecoration(
                                    color: st["dot"],
                                    shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 5),
                              Text(st["label"],
                                  style: TextStyle(
                                      color: st["text"],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        )
                      ],
                    ),

                    const Divider(height: 20),

                    _fila("📞 Teléfono", pedido.telefono),
                    _fila("🕐 Hora entrega", pedido.hora),

                    const SizedBox(height: 8),

                    if (pedido.tipoPedido.isNotEmpty || pedido.pesoTorta.isNotEmpty)
                      const Text("Especificaciones",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),

                    const SizedBox(height: 4),

                    _fila("Tipo de pedido", pedido.tipoPedido),
                    _fila("Tipo de torta", pedido.tipoTorta),
                    _fila("Peso", pedido.pesoTorta),
                    _fila("Sabor", pedido.saborPonque),
                    _fila("Relleno base", pedido.rellenoBase),
                    _fila("Relleno especial", pedido.rellenoEspecial),
                    _fila("Torta especial", pedido.tipeTortaEspecial),
                    _fila("Postres", pedido.postres),

                    const SizedBox(height: 20),

                    if (pedido.estado != "entregado")
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SatoriColors.teal,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: onEntregar,
                          child: const Text("Marcar como entregado"),
                        ),
                      ),

                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: onClose,
                        child: const Text("Cerrar"),
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

class _CircleBtn extends StatelessWidget {
  final String icon;
  final Color color;
  final VoidCallback onTap;

  const _CircleBtn(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SatoriBounce(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration:
            const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
        child: Center(child: Text(icon)),
      ),
    );
  }
}
