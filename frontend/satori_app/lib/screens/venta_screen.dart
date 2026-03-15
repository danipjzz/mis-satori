import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../widgets/bounce.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// ─── MODELOS ─────────────────────────────────────────────────────────────────
class Producto {
  final String id, cat, nombre, desc, emoji;
  final int precio;
  const Producto({required this.id, required this.cat, required this.nombre,
    required this.desc, required this.emoji, required this.precio});
}

class VentaRegistro {
  final String id, producto, fecha, hora, metodoPago;
  final int cantidad, precioUnitario, total;
  final String? cliente, telefono;

  const VentaRegistro({
    required this.id, required this.producto, required this.fecha,
    required this.hora, required this.metodoPago, required this.cantidad,
    required this.precioUnitario, required this.total,
    this.cliente, this.telefono,
  });

  factory VentaRegistro.fromJson(Map j) => VentaRegistro(
    id:             j["id"].toString(),
    producto:       j["producto"] ?? "",
    fecha:          j["fecha"]?.toString().substring(0, 10) ?? "",
    hora:           j["hora"]?.toString().substring(0, 5) ?? "",
    metodoPago:     j["metodo_pago"] ?? "",
    cantidad:       j["cantidad"] ?? 0,
    precioUnitario: j["precio_unitario"] ?? 0,
    total:          j["total"] ?? 0,
    cliente:        j["nombre"],
    telefono:       j["telefono"],
  );
}

// ─── DATOS ───────────────────────────────────────────────────────────────────
const _categorias = [
  {'id': 'all',      'label': '✨ Todo'},
  {'id': 'postres',  'label': '🍰 Postres'},
  {'id': 'bebidas',  'label': '☕ Bebidas'},
];

const _productos = [
  Producto(id:'p1',  cat:'postres', nombre:'Pie de limón',             desc:'', emoji:'🥧', precio:0),
  Producto(id:'p2',  cat:'postres', nombre:'Pie de parchita',          desc:'', emoji:'🥧', precio:0),
  Producto(id:'p3',  cat:'postres', nombre:'Matilda',                  desc:'', emoji:'🍫', precio:0),
  Producto(id:'p4',  cat:'postres', nombre:'Marquesa',                 desc:'', emoji:'🍰', precio:0),
  Producto(id:'p5',  cat:'postres', nombre:'Torta de zanahoria',       desc:'', emoji:'🥕', precio:0),
  Producto(id:'p6',  cat:'postres', nombre:'Quesillo',                 desc:'', emoji:'🍮', precio:0),
  Producto(id:'p7',  cat:'postres', nombre:'Beso de ángel',            desc:'', emoji:'😇', precio:0),
  Producto(id:'p8',  cat:'postres', nombre:'Brigadeiro',               desc:'', emoji:'🍫', precio:0),
  Producto(id:'p9',  cat:'postres', nombre:'Cuchareable de pistacho',  desc:'', emoji:'🥄', precio:0),
  Producto(id:'p10', cat:'postres', nombre:'Cuchareable de samba',     desc:'', emoji:'🥄', precio:0),
  Producto(id:'p11', cat:'postres', nombre:'Tres leches',              desc:'', emoji:'🥛', precio:0),
  Producto(id:'p12', cat:'postres', nombre:'Tres leches de chocolate', desc:'', emoji:'🍫', precio:0),
  Producto(id:'p13', cat:'postres', nombre:'Cheesecake de fresa',      desc:'', emoji:'🍓', precio:0),
  Producto(id:'p14', cat:'postres', nombre:'Tres leches de frutas',    desc:'', emoji:'🍓', precio:0),
  Producto(id:'p15', cat:'postres', nombre:'Torta de auyama',          desc:'', emoji:'🎃', precio:0),
  Producto(id:'p16', cat:'postres', nombre:'Brocookies',               desc:'', emoji:'🍪', precio:0),
  Producto(id:'p17', cat:'postres', nombre:'Otro',                     desc:'Ingresar manualmente', emoji:'✏️', precio:0),
  Producto(id:'b1',  cat:'bebidas', nombre:'Café',                     desc:'', emoji:'☕', precio:0),
  Producto(id:'b2',  cat:'bebidas', nombre:'Agua',                     desc:'', emoji:'💧', precio:0),
  Producto(id:'b3',  cat:'bebidas', nombre:'Malteada',                 desc:'', emoji:'🥤', precio:0),
  Producto(id:'b4',  cat:'bebidas', nombre:'Refresco',                 desc:'', emoji:'🥃', precio:0),
];

const _payMethods = ['💵 Efectivo', '💳 Tarjeta', '📱 Transferencia'];

// ─── SCREEN ──────────────────────────────────────────────────────────────────
class VentaScreen extends StatefulWidget {
  const VentaScreen({super.key});
  @override
  State<VentaScreen> createState() => _VentaScreenState();
}

class _VentaScreenState extends State<VentaScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // POS state
  String _catActiva = 'all';
  final Map<String, int> _carrito = {};
  final Map<String, int> _preciosManual = {};
  bool _showCarrito = false;
  String? _payMethod;
  bool _showSuccess = false;
  final _nombreCtrl   = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _correoCtrl   = TextEditingController();

  // Registro state
  List<VentaRegistro> _ventas = [];
  bool _cargandoVentas = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1) _cargarVentas();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    _correoCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarVentas() async {
    setState(() => _cargandoVentas = true);
    try {
      final res = await http.get(Uri.parse("https://mis-satori.onrender.com/ventas"));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        setState(() => _ventas = data.map((v) => VentaRegistro.fromJson(v)).toList());
      }
    } catch (e) {
      print("Error cargando ventas: $e");
    } finally {
      setState(() => _cargandoVentas = false);
    }
  }

  List<Producto> get _filtrados =>
      _catActiva == 'all' ? _productos : _productos.where((p) => p.cat == _catActiva).toList();

  List<(Producto, int)> get _itemsCarrito =>
      _carrito.entries.map((e) => (_productos.firstWhere((p) => p.id == e.key), e.value)).toList();

  int get _subtotal => _itemsCarrito.fold(0, (acc, item) => acc + (_preciosManual[item.$1.id] ?? item.$1.precio) * item.$2);
  int get _totalItems => _carrito.values.fold(0, (acc, q) => acc + q);

  void _add(String id) => setState(() => _carrito[id] = (_carrito[id] ?? 0) + 1);
  void _sub(String id) => setState(() {
    final q = (_carrito[id] ?? 0) - 1;
    if (q <= 0) _carrito.remove(id); else _carrito[id] = q;
  });

  Future<void> _registrarVenta(String producto, int cantidad, int precio) async {
  final ahora = DateTime.now();
  final fecha = '${ahora.year}-${ahora.month.toString().padLeft(2, '0')}-${ahora.day.toString().padLeft(2, '0')}';

  await http.post(
    Uri.parse("https://mis-satori.onrender.com/ventas"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "producto":        producto,
      "cantidad":        cantidad,
      "precio_unitario": precio,
      "nombre":          _nombreCtrl.text.trim(),
      "telefono":        _telefonoCtrl.text.trim(),
      "correo":          _correoCtrl.text.trim(),
      "metodo_pago":     _payMethod,
      "fecha":           fecha,
    }),
  );
}

  void _cobrar() async {
    if (_payMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona método de pago'))
      );
      return;
    }
    for (var item in _itemsCarrito) {
      await _registrarVenta(item.$1.nombre, item.$2, _preciosManual[item.$1.id] ?? item.$1.precio);
    }
    setState(() => _showSuccess = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() {
        _carrito.clear();
        _payMethod = null;
        _showSuccess = false;
        _showCarrito = false;
        _nombreCtrl.clear();
        _telefonoCtrl.clear();
        _correoCtrl.clear();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SatoriColors.pinkPale,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  _CircleBtn(icon: '‹', color: SatoriColors.pinkPrimary, onTap: () => context.go('/')),
                  Expanded(
                    child: Center(
                      child: ShaderMask(
                        shaderCallback: (b) => const LinearGradient(
                          colors: [SatoriColors.pinkDeep, SatoriColors.textDark],
                        ).createShader(b),
                        child: Text('Punto de Venta',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 28, fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic, color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_tabController.index == 0 && _totalItems > 0)
                    SatoriBounce(
                      onTap: () => setState(() => _showCarrito = true),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 38, height: 38,
                            decoration: BoxDecoration(
                              color: SatoriColors.teal, shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6)],
                            ),
                            child: const Center(child: Text('🛒', style: TextStyle(fontSize: 18))),
                          ),
                          Positioned(
                            top: -4, right: -4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              height: 18,
                              decoration: BoxDecoration(color: SatoriColors.pinkDeep, borderRadius: BorderRadius.circular(9)),
                              child: Center(child: Text('$_totalItems', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800))),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    const SizedBox(width: 38),
                ],
              ),
            ),

            // Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TabBar(
                controller: _tabController,
                onTap: (_) => setState(() {}),
                indicator: BoxDecoration(
                  color: SatoriColors.pinkPrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: SatoriColors.textMid,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                tabs: const [
                  Tab(text: '🛒 Vender'),
                  Tab(text: '📋 Registro'),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _showCarrito ? _buildCarrito() : _buildPOS(),
                  _buildRegistro(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── VISTA POS ──────────────────────────────────────────────────────────────
  Widget _buildPOS() {
    return Column(
      children: [
        SizedBox(
          height: 46,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemCount: _categorias.length,
            itemBuilder: (_, i) {
              final cat = _categorias[i];
              final active = _catActiva == cat['id'];
              return SatoriBounce(
                onTap: () => setState(() => _catActiva = cat['id']!),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                  decoration: BoxDecoration(
                    color: active ? SatoriColors.pinkPrimary : Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: active ? SatoriColors.pinkDeep : Colors.white.withOpacity(0.4), width: 1.5),
                  ),
                  child: Text(cat['label']!, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: active ? Colors.white : SatoriColors.textMid)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: LayoutBuilder(builder: (context, constraints) {
            final crossCount = constraints.maxWidth > 800 ? 5 : (constraints.maxWidth > 500 ? 3 : 2);
            return GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossCount, crossAxisSpacing: 10,
                mainAxisSpacing: 10, childAspectRatio: 0.82,
              ),
              itemCount: _filtrados.length,
              itemBuilder: (_, i) {
                final p = _filtrados[i];
                final qty = _carrito[p.id] ?? 0;
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.emoji, style: const TextStyle(fontSize: 32)),
                      const SizedBox(height: 6),
                      Text(p.nombre, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: SatoriColors.textDark)),
                      const Spacer(),
                      if (qty == 0)
                        SizedBox(
                          width: double.infinity,
                          child: SatoriBounce(
                            onTap: () async {
                              final ctrl = TextEditingController();
                              final precio = await showDialog<int>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text("Precio de ${p.nombre}"),
                                  content: TextField(controller: ctrl, keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(hintText: "Ingresa el precio")),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
                                    ElevatedButton(onPressed: () => Navigator.pop(context, int.tryParse(ctrl.text)), child: const Text("Aceptar")),
                                  ],
                                ),
                              );
                              if (precio != null) setState(() { _preciosManual[p.id] = precio; _add(p.id); });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(color: SatoriColors.teal, borderRadius: BorderRadius.circular(12)),
                              child: const Center(child: Text('Agregar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13))),
                            ),
                          ),
                        )
                      else
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          _CounterBtn(label: '−', onTap: () => _sub(p.id), active: false),
                          const SizedBox(width: 8),
                          Text('$qty', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                          const SizedBox(width: 8),
                          _CounterBtn(label: '+', onTap: () => _add(p.id), active: true),
                        ]),
                    ],
                  ),
                );
              },
            );
          }),
        ),
        if (_totalItems > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SatoriBounce(
              onTap: () => setState(() => _showCarrito = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                decoration: BoxDecoration(
                  color: SatoriColors.pinkPrimary, borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: SatoriColors.pinkDeep.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('🛒 $_totalItems artículo${_totalItems != 1 ? "s" : ""}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                  Text('Ver orden › \$$_subtotal', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
                ]),
              ),
            ),
          ),
      ],
    );
  }

  // ── VISTA CARRITO ──────────────────────────────────────────────────────────
  Widget _buildCarrito() {
    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(children: [
                _CircleBtn(icon: '‹', color: SatoriColors.pinkPrimary, onTap: () => setState(() => _showCarrito = false)),
                const Expanded(child: Center(child: Text('🛒 Tu orden', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: SatoriColors.textDark)))),
                const SizedBox(width: 38),
              ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ..._itemsCarrito.map((item) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)]),
                    child: Row(children: [
                      Text(item.$1.emoji, style: const TextStyle(fontSize: 30)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(item.$1.nombre, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: SatoriColors.textDark)),
                        Text('\$${(_preciosManual[item.$1.id] ?? item.$1.precio) * item.$2}',
                          style: const TextStyle(fontSize: 13, color: SatoriColors.pinkPrimary, fontWeight: FontWeight.w600)),
                      ])),
                      Row(children: [
                        _CounterBtn(label: '−', onTap: () => _sub(item.$1.id), active: false),
                        const SizedBox(width: 8),
                        Text('${item.$2}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                        const SizedBox(width: 8),
                        _CounterBtn(label: '+', onTap: () => _add(item.$1.id), active: true),
                      ]),
                    ]),
                  )),

                  const SizedBox(height: 16),
                  const Text("Datos del cliente (opcional)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: SatoriColors.textDark)),
                  const SizedBox(height: 10),
                  _CampoTexto(ctrl: _nombreCtrl,   hint: "Nombre",           icono: "👤"),
                  const SizedBox(height: 8),
                  _CampoTexto(ctrl: _telefonoCtrl, hint: "Teléfono",          icono: "📞", teclado: TextInputType.phone),
                  const SizedBox(height: 8),
                  _CampoTexto(ctrl: _correoCtrl,   hint: "Correo (opcional)", icono: "✉️", teclado: TextInputType.emailAddress),

                  const SizedBox(height: 16),
                  const Text('Método de pago', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: SatoriColors.textDark)),
                  const SizedBox(height: 10),
                  Wrap(spacing: 8, runSpacing: 8, children: _payMethods.map((m) {
                    final active = _payMethod == m;
                    return SatoriBounce(
                      onTap: () => setState(() => _payMethod = m),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        decoration: BoxDecoration(
                          color: active ? SatoriColors.pinkPrimary : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: active ? SatoriColors.pinkDeep : SatoriColors.pinkLight, width: 1.5),
                        ),
                        child: Text(m, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: active ? Colors.white : SatoriColors.textMid)),
                      ),
                    );
                  }).toList()),

                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 8)]),
                    child: Column(children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text('Subtotal', style: TextStyle(color: SatoriColors.textMid, fontWeight: FontWeight.w600)),
                        Text('\$$_subtotal', style: const TextStyle(color: SatoriColors.textDark, fontWeight: FontWeight.w700)),
                      ]),
                      const SizedBox(height: 8),
                      const Divider(color: SatoriColors.pinkLight),
                      const SizedBox(height: 8),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: SatoriColors.textDark)),
                        Text('\$$_subtotal', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: SatoriColors.tealDark)),
                      ]),
                    ]),
                  ),
                ]),
              ),
            ),
          ],
        ),

        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            color: SatoriColors.pinkPale,
            child: SatoriBounce(
              onTap: _cobrar,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: SatoriColors.teal, borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: SatoriColors.tealDark.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Center(child: Text('Cobrar \$$_subtotal',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.0, color: Colors.white))),
              ),
            ),
          ),
        ),

        if (_showSuccess)
          Container(
            color: Colors.white.withOpacity(0.95),
            child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('✅', style: TextStyle(fontSize: 72)),
              const SizedBox(height: 16),
              const Text('¡Venta registrada!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: SatoriColors.tealDark)),
              const SizedBox(height: 8),
              Text('\$$_subtotal · $_payMethod', style: const TextStyle(fontSize: 16, color: SatoriColors.textMid)),
            ])),
          ),
      ],
    );
  }

  // ── VISTA REGISTRO ─────────────────────────────────────────────────────────
  Widget _buildRegistro() {
    if (_cargandoVentas) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_ventas.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('📋', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          const Text('No hay ventas registradas', style: TextStyle(fontSize: 16, color: SatoriColors.textMid)),
          const SizedBox(height: 16),
          SatoriBounce(
            onTap: _cargarVentas,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(color: SatoriColors.pinkPrimary, borderRadius: BorderRadius.circular(14)),
              child: const Text('Recargar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      );
    }

    // agrupar por fecha
    final Map<String, List<VentaRegistro>> porFecha = {};
    for (var v in _ventas) {
      porFecha.putIfAbsent(v.fecha, () => []).add(v);
    }

    return RefreshIndicator(
      onRefresh: _cargarVentas,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: porFecha.length,
        itemBuilder: (_, i) {
          final fecha = porFecha.keys.elementAt(i);
          final items = porFecha[fecha]!;
          final totalDia = items.fold(0, (acc, v) => acc + v.total);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(fecha, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: SatoriColors.textDark)),
                  Text('Total: \$$totalDia', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: SatoriColors.tealDark)),
                ]),
              ),
              ...items.map((v) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(v.producto, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: SatoriColors.textDark)),
                    Text('\$${v.total}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: SatoriColors.tealDark)),
                  ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    Text('x${v.cantidad}  ·  \$${v.precioUnitario} c/u', style: const TextStyle(fontSize: 12, color: SatoriColors.textMid)),
                    const Spacer(),
                    Text(v.hora, style: const TextStyle(fontSize: 12, color: SatoriColors.textMid)),
                  ]),
                  if (v.cliente != null || v.metodoPago.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    const Divider(height: 1, color: SatoriColors.pinkLight),
                    const SizedBox(height: 6),
                    Row(children: [
                      if (v.cliente != null) ...[
                        const Text('👤 ', style: TextStyle(fontSize: 12)),
                        Text(v.cliente!, style: const TextStyle(fontSize: 12, color: SatoriColors.textMid)),
                        if (v.telefono != null) Text('  📞 ${v.telefono}', style: const TextStyle(fontSize: 12, color: SatoriColors.textMid)),
                      ],
                      const Spacer(),
                      if (v.metodoPago.isNotEmpty)
                        Text(v.metodoPago, style: const TextStyle(fontSize: 12, color: SatoriColors.textMid)),
                    ]),
                  ],
                ]),
              )),
              const Divider(color: SatoriColors.pinkLight),
            ],
          );
        },
      ),
    );
  }
}

// ─── WIDGETS ─────────────────────────────────────────────────────────────────
class _CampoTexto extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint, icono;
  final TextInputType teclado;
  const _CampoTexto({required this.ctrl, required this.hint, required this.icono, this.teclado = TextInputType.text});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)]),
    child: Row(children: [
      Text(icono, style: const TextStyle(fontSize: 18)),
      const SizedBox(width: 10),
      Expanded(child: TextField(controller: ctrl, keyboardType: teclado,
        decoration: InputDecoration(hintText: hint, border: InputBorder.none,
          hintStyle: const TextStyle(color: SatoriColors.textLight)))),
    ]),
  );
}

class _CircleBtn extends StatelessWidget {
  final String icon; final Color color; final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => SatoriBounce(
    onTap: onTap,
    child: Container(
      width: 38, height: 38,
      decoration: BoxDecoration(color: Colors.transparent, shape: BoxShape.circle,
        border: Border.all(color: SatoriColors.pinkLight.withAlpha(80), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)]),
      child: Center(child: Text(icon, style: TextStyle(fontSize: 22, color: color, fontWeight: FontWeight.w700))),
    ),
  );
}

class _CounterBtn extends StatelessWidget {
  final String label; final VoidCallback onTap; final bool active;
  const _CounterBtn({required this.label, required this.onTap, required this.active});

  @override
  Widget build(BuildContext context) => SatoriBounce(
    onTap: onTap,
    child: Container(
      width: 34, height: 34,
      decoration: BoxDecoration(
        color: active ? SatoriColors.teal : SatoriColors.pinkLight, shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: (active ? SatoriColors.teal : SatoriColors.pinkDeep).withAlpha(40), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Center(child: Text(label, style: TextStyle(fontSize: 18, color: active ? Colors.white : SatoriColors.pinkDeep, fontWeight: FontWeight.w700))),
    ),
  );
}