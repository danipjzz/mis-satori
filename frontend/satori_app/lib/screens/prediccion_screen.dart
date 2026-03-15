import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../theme/colors.dart';
import '../widgets/bounce.dart';
import '../services/api_service.dart';

// ─── MODELOS ──────────────────────────────────────────────────────────────────
class ClienteInactivo {
  final String nombre, telefono;
  final String? ultimoPedido;
  const ClienteInactivo({required this.nombre, required this.telefono, this.ultimoPedido});
}

class ClienteMensaje {
  final String nombre, telefono, razon;
  final List pedidos;
  String mensaje;
  bool aprobado;
  bool cargando;

  ClienteMensaje({
    required this.nombre,
    required this.telefono,
    required this.pedidos,
    this.razon = '',
    this.mensaje = '',
    this.aprobado = false,
    this.cargando = false,
  });
}

// ─── SCREEN ──────────────────────────────────────────────────────────────────
class PrediccionScreen extends StatefulWidget {
  const PrediccionScreen({super.key});
  @override
  State<PrediccionScreen> createState() => _PrediccionScreenState();
}

class _PrediccionScreenState extends State<PrediccionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Análisis state
  bool _cargandoAnalisis = true;
  List<ClienteInactivo> _inactivos = [];
  List _pedidosRecientes = [];
  String _analisisIA = '';
  bool _cargandoAnalisisIA = false;

  // Mensajes state
  bool _cargandoClientes = true;
  List<ClienteMensaje> _clientes = [];
  bool _generandoMensajes = false;
  int _mensajesGenerados = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargarAnalisis();
    _cargarClientes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarAnalisis() async {
    setState(() => _cargandoAnalisis = true);
    try {
      final data = await ApiService.getAnalisis();
      setState(() {
        _pedidosRecientes = data['pedidos'] ?? [];
        _inactivos = (data['inactivos'] as List).map((c) => ClienteInactivo(
          nombre: c['nombre'] ?? 'Cliente',
          telefono: c['telefono'] ?? '',
          ultimoPedido: c['ultimo_pedido']?.toString().substring(0, 10),
        )).toList();
        _cargandoAnalisis = false;
      });
    } catch (e) {
      setState(() => _cargandoAnalisis = false);
    }
  }

  Future<void> _cargarClientes() async {
  setState(() => _cargandoClientes = true);
  try {
    final data = await ApiService.getClientesConHistorial();
    final hoy = DateTime.now();

    final filtrados = (data as List)
        .where((c) => c['telefono'] != null && (c['pedidos'] as List?)?.isNotEmpty == true)
        .map((c) {
          final pedidos = (c['pedidos'] as List);
          
          // ordenar pedidos por fecha
          pedidos.sort((a, b) {
            final fa = DateTime.tryParse(a['fecha_entrega']?.toString() ?? '') ?? DateTime(2000);
            final fb = DateTime.tryParse(b['fecha_entrega']?.toString() ?? '') ?? DateTime(2000);
            return fa.compareTo(fb);
          });

          final primerPedido  = DateTime.tryParse(pedidos.first['fecha_entrega']?.toString() ?? '');
          final ultimoPedido  = DateTime.tryParse(pedidos.last['fecha_entrega']?.toString() ?? '');

          // aniversario primer pedido (±7 días este año)
          bool anivPrimero = false;
          if (primerPedido != null) {
            final aniv = DateTime(hoy.year, primerPedido.month, primerPedido.day);
            anivPrimero = aniv.difference(hoy).inDays.abs() <= 7;
          }

          // aniversario último pedido (±7 días este año)
          bool anivUltimo = false;
          if (ultimoPedido != null) {
            final aniv = DateTime(hoy.year, ultimoPedido.month, ultimoPedido.day);
            anivUltimo = aniv.difference(hoy).inDays.abs() <= 7;
          }

          // sin pedir hace más de 60 días
          final inactivo = ultimoPedido != null &&
              hoy.difference(ultimoPedido).inDays > 60;

          // pedido próximo (entrega en los próximos 3 días)
          final proximoPedido = pedidos.any((p) {
            final f = DateTime.tryParse(p['fecha_entrega']?.toString() ?? '');
            if (f == null) return false;
            final diff = f.difference(hoy).inDays;
            return diff >= 0 && diff <= 3;
          });

          // razón del mensaje
          String razon = '';
          if (proximoPedido)  razon = '📦 Pedido próximo';
          else if (anivPrimero) razon = '🎂 Aniversario primer pedido';
          else if (anivUltimo)  razon = '🎉 Aniversario último pedido';
          else if (inactivo)    razon = '😴 Sin pedir hace más de 60 días';

          return razon.isNotEmpty ? ClienteMensaje(
            nombre:  c['nombre'] ?? 'Cliente',
            telefono: c['telefono'],
            pedidos:  pedidos,
            razon:    razon,
          ) : null;
        })
        .where((c) => c != null)
        .cast<ClienteMensaje>()
        .toList();

    // ordenar: primero pedidos próximos, luego aniversarios, luego inactivos
    filtrados.sort((a, b) {
      const orden = {'📦 Pedido próximo': 0, '🎂 Aniversario primer pedido': 1, '🎉 Aniversario último pedido': 2, '😴 Sin pedir hace más de 60 días': 3};
      return (orden[a.razon] ?? 9).compareTo(orden[b.razon] ?? 9);
    });

    setState(() {
      _clientes = filtrados;
      _cargandoClientes = false;
    });
  } catch (e) {
    setState(() => _cargandoClientes = false);
  }
}

  Future<void> _generarTodosMensajes() async {
    setState(() { _generandoMensajes = true; _mensajesGenerados = 0; });

    for (var cliente in _clientes) {
      if (!mounted) break;
      setState(() => cliente.cargando = true);

      try {
        final mensaje = await _generarMensaje(cliente);
        if (mounted) setState(() {
          cliente.mensaje = mensaje;
          cliente.cargando = false;
          _mensajesGenerados++;
        });
      } catch (e) {
        if (mounted) setState(() => cliente.cargando = false);
      }
    }

    if (mounted) setState(() => _generandoMensajes = false);
  }

  Future<String> _generarMensaje(ClienteMensaje cliente) async {
  try {
    final historial = cliente.pedidos.take(5).map((p) {
      final tipo = p['tipo_pedido'] ?? p['tipo_torta'] ?? p['peso_torta'] ?? 'postre';
      final fecha = p['fecha_entrega']?.toString().substring(0, 10) ?? '';
      return '$tipo ($fecha)';
    }).join(', ');

    print("Generando mensaje para ${cliente.nombre}...");

    final res = await http.post(
      Uri.parse('https://mis-satori.onrender.com/ia/mensaje'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre':    cliente.nombre,
        'historial': historial,
        'razon':     cliente.razon,
      }),
    );

    print("Status: ${res.statusCode}");
    print("Body: ${res.body}");

    final data = jsonDecode(res.body);
    return data['mensaje'] ?? '';
  } catch (e) {
    print("Error mensaje: $e");
    return '';
  }
}

  Future<void> _generarAnalisisIA() async {
  setState(() => _cargandoAnalisisIA = true);
  try {
    final resumen = _pedidosRecientes.take(50).map((p) =>
      '${p['tipo_pedido'] ?? p['peso_torta'] ?? 'postre'} - ${p['fecha_entrega']?.toString().substring(0, 10)}'
    ).join('\n');

    print("Enviando a /ia/analisis...");
    
    final res = await http.post(
      Uri.parse('https://mis-satori.onrender.com/ia/analisis'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({ 'resumen': resumen }),
    );

    print("Status: ${res.statusCode}");
    print("Body: ${res.body}");

    final data = jsonDecode(res.body);
    setState(() {
      _analisisIA = data['analisis'] ?? '';
      _cargandoAnalisisIA = false;
    });
  } catch (e) {
    print("Error analisis: $e");
    setState(() => _cargandoAnalisisIA = false);
  }
}

  void _enviarWhatsApp(ClienteMensaje cliente) async {
    final tel = cliente.telefono.replaceAll(RegExp(r'[^0-9]'), '');
    final msg = Uri.encodeComponent(cliente.mensaje);
    final url = 'https://wa.me/$tel?text=$msg';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  // Calcular top productos de datos reales
  Map<String, int> get _topProductos {
    final Map<String, int> conteo = {};
    for (var p in _pedidosRecientes) {
      final key = p['tipo_pedido'] ?? p['tipo_torta'] ?? p['peso_torta'] ?? 'Otro';
      if (key != null) conteo[key] = (conteo[key] ?? 0) + 1;
    }
    final sorted = conteo.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted.take(5));
  }

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
                        child: Text('Inteligencia',
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

            // Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: const Color(0xFFB8860B),
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: SatoriColors.textMid,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                tabs: const [
                  Tab(text: '📊 Análisis'),
                  Tab(text: '💬 Mensajes'),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildAnalisis(),
                  _buildMensajes(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── TAB ANÁLISIS ───────────────────────────────────────────────────────────
  Widget _buildAnalisis() {
    if (_cargandoAnalisis) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _cargarAnalisis,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 8),

            // KPIs
            Row(children: [
              _KpiCard('📦', '${_pedidosRecientes.length}', 'Pedidos 6 meses', Colors.white, SatoriColors.teal),
              const SizedBox(width: 12),
              _KpiCard('😴', '${_inactivos.length}', 'Clientes inactivos', Colors.white, SatoriColors.pinkPrimary),
              const SizedBox(width: 12),
              _KpiCard('👥', '${_clientes.length}', 'Total clientes', Colors.white, const Color(0xFFB8860B)),
            ]),

            const SizedBox(height: 20),

            // Top productos reales
            if (_topProductos.isNotEmpty) ...[
              const Text('Más pedidos (últimos 6 meses)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: SatoriColors.textDark, letterSpacing: -0.4)),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
                ),
                child: Column(
                  children: _topProductos.entries.toList().asMap().entries.map((entry) {
                    final i = entry.key;
                    final nombre = entry.value.key;
                    final count = entry.value.value;
                    final max = _topProductos.values.first;
                    final pct = count / max;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(
                          color: i < _topProductos.length - 1 ? SatoriColors.pinkPale : Colors.transparent,
                          width: 0.5,
                        )),
                      ),
                      child: Row(children: [
                        Text('${i+1}', style: GoogleFonts.cormorantGaramond(
                          fontSize: 18, fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic, color: SatoriColors.pinkPrimary,
                        )),
                        const SizedBox(width: 14),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(nombre, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: SatoriColors.textDark)),
                          const SizedBox(height: 4),
                          Text('$count pedidos', style: const TextStyle(fontSize: 12, color: SatoriColors.textMid)),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: pct,
                              backgroundColor: SatoriColors.pinkPale.withOpacity(0.5),
                              valueColor: AlwaysStoppedAnimation(
                                i == 0 ? SatoriColors.teal : SatoriColors.pinkPrimary.withOpacity(0.6)
                              ),
                              minHeight: 4,
                            ),
                          ),
                        ])),
                      ]),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Análisis IA
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: SatoriColors.tealPale.withOpacity(0.4),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: SatoriColors.tealLight.withOpacity(0.3), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('🔮 Predicción IA',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: SatoriColors.tealDark)),
                    if (!_cargandoAnalisisIA)
                      SatoriBounce(
                        onTap: _generarAnalisisIA,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: SatoriColors.teal,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(_analisisIA.isEmpty ? 'Analizar' : 'Regenerar',
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                        ),
                      ),
                  ]),
                  if (_cargandoAnalisisIA) ...[
                    const SizedBox(height: 16),
                    const Center(child: CircularProgressIndicator()),
                  ] else if (_analisisIA.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(_analisisIA,
                      style: const TextStyle(fontSize: 14, color: SatoriColors.tealDark, height: 1.6)),
                  ] else ...[
                    const SizedBox(height: 8),
                    const Text('Toca "Analizar" para obtener predicciones basadas en tu historial real.',
                      style: TextStyle(fontSize: 13, color: SatoriColors.textMid)),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ── TAB MENSAJES ───────────────────────────────────────────────────────────
  Widget _buildMensajes() {
    if (_cargandoClientes) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${_clientes.length} clientes',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: SatoriColors.textDark)),
                if (_generandoMensajes)
                  Text('Generando... $_mensajesGenerados/${_clientes.length}',
                    style: const TextStyle(fontSize: 12, color: SatoriColors.textMid)),
              ]),
            ),
            if (!_generandoMensajes)
              SatoriBounce(
                onTap: _generarTodosMensajes,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB8860B),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: const Color(0xFFB8860B).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
                  ),
                  child: const Text('✨ Generar todos',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                ),
              )
            else
              const CircularProgressIndicator(),
          ]),
        ),

        const SizedBox(height: 8),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _clientes.length,
            itemBuilder: (_, i) {
              final cliente = _clientes[i];
              return _TarjetaMensaje(
                cliente: cliente,
                onEnviar: () => _enviarWhatsApp(cliente),
                onEditar: (texto) => setState(() => cliente.mensaje = texto),
                onRegenerarUno: () async {
                  setState(() => cliente.cargando = true);
                  final msg = await _generarMensaje(cliente);
                  setState(() { cliente.mensaje = msg; cliente.cargando = false; });
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── TARJETA MENSAJE ──────────────────────────────────────────────────────────
class _TarjetaMensaje extends StatefulWidget {
  final ClienteMensaje cliente;
  final VoidCallback onEnviar;
  final Function(String) onEditar;
  final VoidCallback onRegenerarUno;

  const _TarjetaMensaje({
    required this.cliente,
    required this.onEnviar,
    required this.onEditar,
    required this.onRegenerarUno,
  });

  @override
  State<_TarjetaMensaje> createState() => _TarjetaMensajeState();
}

class _TarjetaMensajeState extends State<_TarjetaMensaje> {
  bool _editando = false;
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.cliente.mensaje);
  }

  @override
  void didUpdateWidget(_TarjetaMensaje old) {
    super.didUpdateWidget(old);
    if (widget.cliente.mensaje != old.cliente.mensaje) {
      _ctrl.text = widget.cliente.mensaje;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cliente = widget.cliente;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        border: cliente.aprobado ? Border.all(color: SatoriColors.teal, width: 1.5) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(cliente.nombre,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: SatoriColors.textDark)),
              Text('📞 ${cliente.telefono}',
                style: const TextStyle(fontSize: 12, color: SatoriColors.textMid)),
                if (cliente.razon.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: SatoriColors.yellowLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(cliente.razon,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFB8860B))),
                ),
            ])),
            if (cliente.aprobado)
              const Text('✅', style: TextStyle(fontSize: 20)),
          ]),

          if (cliente.cargando) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ] else if (cliente.mensaje.isNotEmpty) ...[
            const SizedBox(height: 12),
            if (_editando)
              TextField(
                controller: _ctrl,
                maxLines: null,
                onChanged: widget.onEditar,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: SatoriColors.yellowLight,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.all(12),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: SatoriColors.yellowLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(cliente.mensaje,
                  style: const TextStyle(fontSize: 13, color: SatoriColors.textDark, height: 1.5)),
              ),

            const SizedBox(height: 10),
            Row(children: [
              // Editar
              SatoriBounce(
                onTap: () => setState(() => _editando = !_editando),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(color: SatoriColors.pinkPale, borderRadius: BorderRadius.circular(10)),
                  child: Text(_editando ? 'Listo' : '✏️ Editar',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: SatoriColors.pinkDeep)),
                ),
              ),
              const SizedBox(width: 6),
              // Regenerar
              SatoriBounce(
                onTap: widget.onRegenerarUno,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(color: SatoriColors.yellowLight, borderRadius: BorderRadius.circular(10)),
                  child: const Text('🔄 Regenerar',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFB8860B))),
                ),
              ),
              const Spacer(),
              // copiar mensaje
              SatoriBounce(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: widget.cliente.mensaje));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Mensaje copiado'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: SatoriColors.teal,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('📋 Copiar',
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          ] else ...[
            const SizedBox(height: 10),
            SatoriBounce(
              onTap: widget.onRegenerarUno,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFB8860B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFB8860B).withOpacity(0.3)),
                ),
                child: const Center(child: Text('✨ Generar mensaje',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFB8860B)))),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── WIDGETS ─────────────────────────────────────────────────────────────────
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
        boxShadow: [BoxShadow(color: accent.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(children: [
        Text(emoji, style: const TextStyle(fontSize: 26)),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: SatoriColors.textDark), textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: SatoriColors.textMid), textAlign: TextAlign.center),
      ]),
    ),
  );
}