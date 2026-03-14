import 'dart:ui';
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

// ─── DATOS ───────────────────────────────────────────────────────────────────
const _categorias = [
  {'id': 'all',      'label': '✨ Todo'},
  {'id': 'pasteles', 'label': '🎂 Pasteles'},
  {'id': 'cupcakes', 'label': '🧁 Cupcakes'},
  {'id': 'galletas', 'label': '🍪 Galletas'},
  {'id': 'pays',     'label': '🥧 Pays'},
  {'id': 'bebidas',  'label': '☕ Bebidas'},
];

const _productos = [
  Producto(id:'p1', cat:'postres', nombre:'Pie de limón', desc:'', emoji:'🥧', precio:0),
  Producto(id:'p2', cat:'postres', nombre:'Pie de parchita', desc:'', emoji:'🥧', precio:0),
  Producto(id:'p3', cat:'postres', nombre:'Matilda', desc:'', emoji:'🍫', precio:0),
  Producto(id:'p4', cat:'postres', nombre:'Marquesa', desc:'', emoji:'🍰', precio:0),
  Producto(id:'p5', cat:'postres', nombre:'Torta de zanahoria', desc:'', emoji:'🥕', precio:0),
  Producto(id:'p6', cat:'postres', nombre:'Quesillo', desc:'', emoji:'🍮', precio:0),
  Producto(id:'p7', cat:'postres', nombre:'Beso de ángel', desc:'', emoji:'😇', precio:0),
  Producto(id:'p8', cat:'postres', nombre:'Brigadeiro', desc:'', emoji:'🍫', precio:0),
  Producto(id:'p9', cat:'postres', nombre:'Cuchareable de pistacho', desc:'', emoji:'🥄', precio:0),
  Producto(id:'p10', cat:'postres', nombre:'Cuchareable de samba', desc:'', emoji:'🥄', precio:0),
  Producto(id:'p11', cat:'postres', nombre:'Tres leches', desc:'', emoji:'🥛', precio:0),
  Producto(id:'p12', cat:'postres', nombre:'Tres leches de chocolate', desc:'', emoji:'🍫', precio:0),
  Producto(id:'p13', cat:'postres', nombre:'Cheesecake de fresa', desc:'', emoji:'🍓', precio:0),
  Producto(id:'p14', cat:'postres', nombre:'Tres leches de frutas', desc:'', emoji:'🍓', precio:0),
  Producto(id:'p15', cat:'postres', nombre:'Torta de auyama', desc:'', emoji:'🎃', precio:0),
  Producto(id:'p16', cat:'postres', nombre:'Brocookies', desc:'', emoji:'🍪', precio:0),
  Producto(id:'p17', cat:'postres', nombre:'Otro', desc:'Ingresar manualmente', emoji:'✏️', precio:0),
];

const _payMethods = ['💵 Efectivo', '💳 Tarjeta', '📱 Transferencia'];

// ─── SCREEN ──────────────────────────────────────────────────────────────────
class VentaScreen extends StatefulWidget {
  const VentaScreen({super.key});
  @override
  State<VentaScreen> createState() => _VentaScreenState();
}


class _VentaScreenState extends State<VentaScreen> {
  Future<void> registrarVenta(
  String producto,
  int cantidad,
  int precio,
) async {

  final url = Uri.parse("https://mis-satori.onrender.com/ventas");

  await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "producto": producto,
      "cantidad": cantidad,
      "precio_unitario": precio
    }),
  );
} 
  String _catActiva = 'all';
  final Map<String, int> _carrito = {};
  final Map<String, int> _preciosManual = {};
  bool _showCarrito = false;
  String? _payMethod;
  bool _showSuccess = false;

  List<Producto> get _filtrados =>
      _catActiva == 'all' ? _productos : _productos.where((p) => p.cat == _catActiva).toList();

  List<(Producto, int)> get _itemsCarrito =>
      _carrito.entries.map((e) => (_productos.firstWhere((p) => p.id == e.key), e.value)).toList();

  int get _subtotal => _itemsCarrito.fold(0, (acc, item) => acc + item.$1.precio * item.$2);
  int get _totalItems => _carrito.values.fold(0, (acc, q) => acc + q);

  void _add(String id) => setState(() => _carrito[id] = (_carrito[id] ?? 0) + 1);
  void _sub(String id) => setState(() {
    final q = (_carrito[id] ?? 0) - 1;
    if (q <= 0) _carrito.remove(id); else _carrito[id] = q;
  });

  void _cobrar() async {

  if (_payMethod == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Selecciona método de pago'))
    );
    return;
  }

  for (var item in _itemsCarrito) {

    final producto = item.$1.nombre;
    final cantidad = item.$2;
    final precio = item.$1.precio;

    await registrarVenta(producto, cantidad, precio);
  }

  setState(() => _showSuccess = true);

  Future.delayed(const Duration(seconds: 2), () {
    if (mounted) setState(() {
      _carrito.clear();
      _payMethod = null;
      _showSuccess = false;
      _showCarrito = false;
    });
  });
}

  @override
  Widget build(BuildContext context) {
    if (_showCarrito) return _buildCarrito();
    return _buildPOS();
  }

  // ── VISTA POS ──────────────────────────────────────────────────────────────
  Widget _buildPOS() {
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
                        child: Text(
                          'Punto de Venta',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 28, fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic, color: Colors.white,
                            letterSpacing: -1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SatoriBounce(
                    onTap: _totalItems > 0 ? () => setState(() => _showCarrito = true) : null,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 38, height: 38,
                            decoration: BoxDecoration(
                              color: _totalItems > 0 ? SatoriColors.teal : SatoriColors.white,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6)],
                            ),
                            child: const Center(child: Text('🛒', style: TextStyle(fontSize: 18))),
                          ),
                          if (_totalItems > 0)
                            Positioned(
                              top: -4, right: -4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                height: 18,
                                decoration: BoxDecoration(color: SatoriColors.pinkDeep, borderRadius: BorderRadius.circular(9)),
                                child: Center(child: Text('$_totalItems', style: const TextStyle(color: SatoriColors.white, fontSize: 10, fontWeight: FontWeight.w800))),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Categorías
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
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE2E8F0).withOpacity(active ? 0.4 : 0.2),
                            blurRadius: 10, offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(cat['label']!, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: active ? SatoriColors.white : SatoriColors.textMid)),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Grid de productos
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final crossCount = constraints.maxWidth > 800 ? 5 : (constraints.maxWidth > 500 ? 3 : 2);
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossCount, 
                      crossAxisSpacing: 10, 
                      mainAxisSpacing: 10, 
                      childAspectRatio: 0.82,
                    ),
                    itemCount: _filtrados.length,
                    itemBuilder: (_, i) {
                      final p = _filtrados[i];
                      final qty = _carrito[p.id] ?? 0;
                      return MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.emoji, style: const TextStyle(fontSize: 32)),
                              const SizedBox(height: 6),
                              Text(p.nombre, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: SatoriColors.textDark, letterSpacing: -0.5)),
                              const SizedBox(height: 2),
                              Text(p.desc, style: const TextStyle(fontSize: 11, color: SatoriColors.textLight)),
                              const SizedBox(height: 8),
                              Text('\$${p.precio}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: SatoriColors.pinkPrimary)),
                              const Spacer(),
                              if (qty == 0)
                                SizedBox(
                                  width: double.infinity,
                                  child: SatoriBounce(
                                    onTap: () async {

                                        final controller = TextEditingController();

                                        final precio = await showDialog<int>(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: Text("Precio de ${p.nombre}"),
                                            content: TextField(
                                              controller: controller,
                                              keyboardType: TextInputType.number,
                                              decoration: const InputDecoration(
                                                hintText: "Ingresa el precio",
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text("Cancelar"),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  final value = int.tryParse(controller.text);
                                                  Navigator.pop(context, value);
                                                },
                                                child: const Text("Aceptar"),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (precio != null) {
                                          setState(() {
                                            _preciosManual[p.id] = precio;
                                            _add(p.id);
                                          });
                                        }
                                      },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        color: SatoriColors.teal,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [BoxShadow(color: SatoriColors.teal.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3))],
                                      ),
                                      child: const Center(child: Text('Agregar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5))),
                                    ),
                                  ),
                                )
                              else
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _CounterBtn(label: '−', onTap: () => _sub(p.id), active: false),
                                    const SizedBox(width: 8),
                                    Text('$qty', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: SatoriColors.textDark)),
                                    const SizedBox(width: 8),
                                    _CounterBtn(label: '+', onTap: () => _add(p.id), active: true),
                                  ],
                                ),
                            ],
                          ),
                        ),
                       );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // Barra flotante (CTA)
      bottomNavigationBar: _totalItems > 0
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SatoriBounce(
                  onTap: () => setState(() => _showCarrito = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                    decoration: BoxDecoration(
                      color: SatoriColors.pinkPrimary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: SatoriColors.pinkDeep.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('🛒 $_totalItems artículo${_totalItems != 1 ? "s" : ""}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                        Text('Ver orden › \$$_subtotal', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  // ── VISTA CARRITO ──────────────────────────────────────────────────────────
  Widget _buildCarrito() {
    return Scaffold(
      backgroundColor: SatoriColors.pinkPale,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      _CircleBtn(icon: '‹', color: SatoriColors.pinkPrimary, onTap: () => setState(() => _showCarrito = false)),
                      const Expanded(child: Center(child: Text('🛒 Tu orden', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: SatoriColors.textDark)))),
                      const SizedBox(width: 38),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Items
                        ..._itemsCarrito.map((item) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: SatoriColors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)]),
                          child: Row(
                            children: [
                              Text(item.$1.emoji, style: const TextStyle(fontSize: 30)),
                              const SizedBox(width: 12),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(item.$1.nombre, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: SatoriColors.textDark)),
                                Text('\$${item.$1.precio * item.$2}', style: const TextStyle(fontSize: 13, color: SatoriColors.pinkPrimary, fontWeight: FontWeight.w600)),
                              ])),
                              Row(children: [
                                _CounterBtn(label: '−', onTap: () => _sub(item.$1.id), active: false),
                                const SizedBox(width: 8),
                                Text('${item.$2}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                                const SizedBox(width: 8),
                                _CounterBtn(label: '+', onTap: () => _add(item.$1.id), active: true),
                              ]),
                            ],
                          ),
                        )),

                        const SizedBox(height: 8),
                        const Text('Método de pago', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: SatoriColors.textDark)),
                        const SizedBox(height: 10),
                        Wrap(spacing: 8, runSpacing: 8, children: _payMethods.map((m) {
                          final active = _payMethod == m;
                          return SatoriBounce(
                            onTap: () => setState(() => _payMethod = m),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                              decoration: BoxDecoration(
                                color: active ? SatoriColors.pinkPrimary : SatoriColors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: active ? SatoriColors.pinkDeep : SatoriColors.pinkLight, width: 1.5),
                                boxShadow: [if(!active) BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))],
                              ),
                              child: Text(m, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: active ? SatoriColors.white : SatoriColors.textMid)),
                            ),
                          );
                        }).toList()),

                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(color: SatoriColors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 8)]),
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
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Botón cobrar
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              color: SatoriColors.pinkPale,
              child: SatoriBounce(
                onTap: _cobrar,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: SatoriColors.teal,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: SatoriColors.tealDark.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Center(
                    child: Text('Cobrar \$$_subtotal', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.0, color: Colors.white)),
                  ),
                ),
              ),
            ),
          ),

          // Pantalla de éxito
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
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final String icon;
  final Color color;
  final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => SatoriBounce(
    onTap: onTap,
    child: Container(
      width: 38, height: 38,
      decoration: BoxDecoration(
        color: Colors.transparent, 
        shape: BoxShape.circle,
        border: Border.all(color: SatoriColors.pinkLight.withAlpha(80), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
      ),
      child: Center(child: Text(icon, style: TextStyle(fontSize: 22, color: color, fontWeight: FontWeight.w700))),
    ),
  );
}

class _CounterBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool active;
  const _CounterBtn({required this.label, required this.onTap, required this.active});

  @override
  Widget build(BuildContext context) => SatoriBounce(
    onTap: onTap,
    child: Container(
      width: 34, height: 34,
      decoration: BoxDecoration(
        color: active ? SatoriColors.teal : SatoriColors.pinkLight,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (active ? SatoriColors.teal : SatoriColors.pinkDeep).withAlpha(40),
            blurRadius: 4, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(child: Text(label, style: TextStyle(fontSize: 18, color: active ? SatoriColors.white : SatoriColors.pinkDeep, fontWeight: FontWeight.w700))),
    ),
  );
}
