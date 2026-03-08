// lib/screens/venta_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/colors.dart';

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
  Producto(id:'p1', cat:'pasteles', nombre:'Pastel Vainilla',    desc:'1 kg, personalizable',  emoji:'🍰', precio:380),
  Producto(id:'p2', cat:'pasteles', nombre:'Pastel Chocolate',   desc:'1 kg, betún oscuro',     emoji:'🎂', precio:400),
  Producto(id:'p3', cat:'pasteles', nombre:'Pastel Red Velvet',  desc:'1 kg, relleno queso',    emoji:'❤️', precio:420),
  Producto(id:'p4', cat:'pasteles', nombre:'Tres Leches',        desc:'1 kg, crema chantilly',  emoji:'🥛', precio:360),
  Producto(id:'p5', cat:'pasteles', nombre:'Pastel Zanahoria',   desc:'1 kg, nuez y crema',     emoji:'🥕', precio:390),
  Producto(id:'c1', cat:'cupcakes', nombre:'Cupcake Vainilla',   desc:'Con betún decorado',     emoji:'🧁', precio:35),
  Producto(id:'c2', cat:'cupcakes', nombre:'Cupcake Choco',      desc:'Relleno de ganache',     emoji:'🍫', precio:38),
  Producto(id:'c3', cat:'cupcakes', nombre:'Cupcake Fresa',      desc:'Con fresas frescas',     emoji:'🍓', precio:40),
  Producto(id:'c4', cat:'cupcakes', nombre:'Cupcake Limón',      desc:'Betún de merengue',      emoji:'🍋', precio:36),
  Producto(id:'g1', cat:'galletas', nombre:'Galleta Chispas',    desc:'Chips de chocolate',     emoji:'🍪', precio:22),
  Producto(id:'g2', cat:'galletas', nombre:'Galleta Decorada',   desc:'Con glasé artístico',    emoji:'🌸', precio:35),
  Producto(id:'g3', cat:'galletas', nombre:'Caja Galletas x12', desc:'Mix de sabores',         emoji:'📦', precio:280),
  Producto(id:'py1',cat:'pays',     nombre:'Pay Queso',          desc:'Con frutos rojos',       emoji:'🧀', precio:250),
  Producto(id:'py2',cat:'pays',     nombre:'Pay Manzana',        desc:'Con canela',             emoji:'🍎', precio:230),
  Producto(id:'py3',cat:'pays',     nombre:'Pay Limón',          desc:'Merengue italiano',      emoji:'🍋', precio:220),
  Producto(id:'b1', cat:'bebidas',  nombre:'Café Latte',         desc:'Leche espumada',         emoji:'☕', precio:55),
  Producto(id:'b2', cat:'bebidas',  nombre:'Chocolate Caliente', desc:'Con marshmallows',       emoji:'🍫', precio:50),
  Producto(id:'b3', cat:'bebidas',  nombre:'Frappé Vainilla',    desc:'Con crema batida',       emoji:'🥤', precio:65),
];

const _payMethods = ['💵 Efectivo', '💳 Tarjeta', '📱 Transferencia'];

// ─── SCREEN ──────────────────────────────────────────────────────────────────
class VentaScreen extends StatefulWidget {
  const VentaScreen({super.key});
  @override
  State<VentaScreen> createState() => _VentaScreenState();
}

class _VentaScreenState extends State<VentaScreen> {
  String _catActiva = 'all';
  final Map<String, int> _carrito = {};
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

  void _cobrar() {
    if (_payMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona método de pago')));
      return;
    }
    setState(() => _showSuccess = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() {
        _carrito.clear(); _payMethod = null; _showSuccess = false; _showCarrito = false;
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
                  const Expanded(child: Center(child: Text('🧾 Punto de Venta', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: SatoriColors.textDark)))),
                  GestureDetector(
                    onTap: _totalItems > 0 ? () => setState(() => _showCarrito = true) : null,
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
                  return GestureDetector(
                    onTap: () => setState(() => _catActiva = cat['id']!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                      decoration: BoxDecoration(
                        color: active ? SatoriColors.pinkPrimary : SatoriColors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: active ? SatoriColors.pinkDeep : Colors.transparent, width: 1.5),
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
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.85,
                ),
                itemCount: _filtrados.length,
                itemBuilder: (_, i) {
                  final p = _filtrados[i];
                  final qty = _carrito[p.id] ?? 0;
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: SatoriColors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 8, offset: const Offset(0, 3))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.emoji, style: const TextStyle(fontSize: 32)),
                        const SizedBox(height: 6),
                        Text(p.nombre, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: SatoriColors.textDark)),
                        const SizedBox(height: 2),
                        Text(p.desc, style: const TextStyle(fontSize: 11, color: SatoriColors.textLight)),
                        const SizedBox(height: 8),
                        Text('\$${p.precio}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: SatoriColors.pinkPrimary)),
                        const Spacer(),
                        if (qty == 0)
                          GestureDetector(
                            onTap: () => _add(p.id),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(color: SatoriColors.pinkLight, borderRadius: BorderRadius.circular(10)),
                              child: const Center(child: Text('Agregar', style: TextStyle(color: SatoriColors.pinkDeep, fontWeight: FontWeight.w700, fontSize: 13))),
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
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // Barra flotante
      bottomNavigationBar: _totalItems > 0
          ? GestureDetector(
              onTap: () => setState(() => _showCarrito = true),
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                decoration: BoxDecoration(color: SatoriColors.textDark, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 14, offset: const Offset(0, 4))]),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('🛒 $_totalItems artículo${_totalItems != 1 ? "s" : ""}', style: const TextStyle(color: SatoriColors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    Text('Ver orden › \$$_subtotal', style: const TextStyle(color: SatoriColors.teal, fontSize: 14, fontWeight: FontWeight.w700)),
                  ],
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
                        Wrap(spacing: 8, children: _payMethods.map((m) {
                          final active = _payMethod == m;
                          return GestureDetector(
                            onTap: () => setState(() => _payMethod = m),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                              decoration: BoxDecoration(
                                color: active ? SatoriColors.pinkPrimary : SatoriColors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: active ? SatoriColors.pinkDeep : SatoriColors.pinkLight, width: 1.5),
                              ),
                              child: Text(m, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: active ? SatoriColors.white : SatoriColors.textMid)),
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
              child: ElevatedButton(
                onPressed: _cobrar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SatoriColors.pinkPrimary, foregroundColor: SatoriColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 6, shadowColor: SatoriColors.pinkDeep,
                ),
                child: Text('Cobrar \$$_subtotal', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
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
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 38, height: 38,
      decoration: BoxDecoration(color: SatoriColors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6)]),
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
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 28, height: 28,
      decoration: BoxDecoration(
        color: active ? SatoriColors.teal : SatoriColors.pinkLight,
        shape: BoxShape.circle,
      ),
      child: Center(child: Text(label, style: TextStyle(fontSize: 18, color: active ? SatoriColors.white : SatoriColors.pinkDeep, fontWeight: FontWeight.w700))),
    ),
  );
}
