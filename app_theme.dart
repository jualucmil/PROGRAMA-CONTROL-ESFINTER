import 'package:flutter/material.dart';
import '../models/nino.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import 'menu_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> _recientes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRecientes();
  }

  Future<void> _loadRecientes() async {
    final nombres = await DatabaseService.getUltimosNombres();
    setState(() {
      _recientes = nombres;
      _loading = false;
    });
  }

  Future<void> _entrar() async {
    final nombre = _controller.text.trim();
    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor escribe el nombre del niño')),
      );
      return;
    }
    final nino = await DatabaseService.upsertNino(nombre);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => MenuScreen(nino: nino)),
    );
  }

  Future<void> _mostrarEliminar() async {
    final ninos = await DatabaseService.getAllNinos();
    if (!mounted) return;
    if (ninos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay sujetos guardados')),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _EliminarSheet(ninos: ninos, onDeleted: _loadRecientes),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1565C0), Color(0xFF1976D2), Color(0xFFF5F7FA)],
            stops: [0.0, 0.35, 0.35],
          ),
        ),
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : Column(
                  children: [
                    const SizedBox(height: 40),
                    // Header
                    const Icon(Icons.child_care, size: 72, color: Colors.white),
                    const SizedBox(height: 12),
                    const Text(
                      'Control de Esfínteres',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Seguimiento Infantil',
                      style: TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                    const SizedBox(height: 40),
                    // Card
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 20,
                              offset: const Offset(0, -5),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '¿Quién va al baño hoy?',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextField(
                                controller: _controller,
                                decoration: const InputDecoration(
                                  labelText: 'Nombre del niño',
                                  prefixIcon: Icon(Icons.person_outline,
                                      color: AppTheme.primary),
                                ),
                                textCapitalization: TextCapitalization.words,
                                style: const TextStyle(fontSize: 17),
                              ),
                              if (_recientes.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                const Text(
                                  'Usados recientemente:',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _recientes
                                      .map((n) => ActionChip(
                                            label: Text(n),
                                            avatar: const Icon(
                                                Icons.person_pin_outlined,
                                                size: 18),
                                            backgroundColor:
                                                const Color(0xFFE3F2FD),
                                            labelStyle: const TextStyle(
                                              color: AppTheme.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            onPressed: () {
                                              _controller.text = n;
                                              _entrar();
                                            },
                                          ))
                                      .toList(),
                                ),
                              ],
                              const SizedBox(height: 28),
                              ElevatedButton.icon(
                                onPressed: _entrar,
                                icon: const Icon(Icons.login, size: 24),
                                label: const Text('ENTRAR'),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: _mostrarEliminar,
                                icon: const Icon(Icons.delete_forever,
                                    color: AppTheme.danger),
                                label: const Text(
                                  'Eliminar Registros',
                                  style: TextStyle(
                                    color: AppTheme.danger,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 56),
                                  side: const BorderSide(
                                      color: AppTheme.danger, width: 1.5),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
        ),
      ),
    );
  }
}

class _EliminarSheet extends StatelessWidget {
  final List<Nino> ninos;
  final VoidCallback onDeleted;

  const _EliminarSheet({required this.ninos, required this.onDeleted});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Eliminar Sujeto y Sus Registros',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.danger,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              'Selecciona el niño a eliminar. Esta acción es PERMANENTE.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
          ),
          const Divider(),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: ninos.length,
              itemBuilder: (ctx, i) {
                final n = ninos[i];
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFEBEE),
                    child: Icon(Icons.person, color: AppTheme.danger),
                  ),
                  title: Text(n.nombre,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.delete, color: AppTheme.danger),
                  onTap: () => _confirmar(context, n),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _confirmar(BuildContext context, Nino n) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('⚠️ Confirmar Eliminación'),
        content: Text(
          '¿Estás seguro de que quieres eliminar a "${n.nombre}" y TODOS sus registros históricos?\n\nEsta acción NO se puede deshacer.',
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              await DatabaseService.eliminarNino(n.id!);
              if (context.mounted) {
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // close sheet
                onDeleted();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${n.nombre} eliminado correctamente'),
                    backgroundColor: AppTheme.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('SÍ, ELIMINAR'),
          ),
        ],
      ),
    );
  }
}