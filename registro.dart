import 'package:flutter/material.dart';
import '../models/nino.dart';
import '../theme/app_theme.dart';
import '../services/database_service.dart';
import '../services/pdf_service.dart';
import 'registro_screen.dart';
import 'matriz_screen.dart';
import 'login_screen.dart';

class MenuScreen extends StatelessWidget {
  final Nino nino;

  const MenuScreen({super.key, required this.nino});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú Principal'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Subject card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.child_care, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Sujeto activo',
                            style: TextStyle(color: Colors.white70, fontSize: 13)),
                        Text(
                          nino.nombre,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Selecciona una acción:',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              // Button 1
              _MenuButton(
                icon: Icons.edit_note,
                label: 'Nuevo Registro',
                sublabel: 'Iniciar sesión de baño',
                color: AppTheme.primary,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RegistroScreen(nino: nino)),
                ),
              ),
              const SizedBox(height: 14),
              // Button 2
              _MenuButton(
                icon: Icons.grid_view_rounded,
                label: 'Cuadrante Semanal',
                sublabel: 'Ver matriz 9:00 – 14:00',
                color: const Color(0xFF00838F),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MatrizScreen(nino: nino)),
                ),
              ),
              const SizedBox(height: 14),
              // Button 3
              _MenuButton(
                icon: Icons.picture_as_pdf,
                label: 'Informe 30 Días (PDF)',
                sublabel: 'Exportar histórico mensual',
                color: const Color(0xFF6A1B9A),
                onTap: () async {
                  final registros = await DatabaseService.getRegistros30Dias(nino.id!);
                  if (context.mounted) {
                    await PdfService.print30Dias(nino.nombre, nino.id!, registros);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback onTap;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: color,
                        )),
                    Text(sublabel,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        )),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: color.withOpacity(0.6), size: 28),
            ],
          ),
        ),
      ),
    );
  }
}