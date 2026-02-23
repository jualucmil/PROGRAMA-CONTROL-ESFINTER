import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/nino.dart';
import '../models/registro.dart';
import '../services/database_service.dart';
import '../services/pdf_service.dart';
import '../theme/app_theme.dart';
import '../widgets/celda_widget.dart';

class MatrizScreen extends StatefulWidget {
  final Nino nino;
  const MatrizScreen({super.key, required this.nino});

  @override
  State<MatrizScreen> createState() => _MatrizScreenState();
}

class _MatrizScreenState extends State<MatrizScreen> {
  static const _horas = [
    '9:00','9:30','10:00','10:30','11:00','11:30',
    '12:00','12:30','13:00','13:30','14:00',
  ];
  static const _diasLabel = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie'];

  late DateTime _monday;
  List<Registro> _registros = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _monday = _getMondayOf(DateTime.now());
    _loadData();
  }

  DateTime _getMondayOf(DateTime d) =>
      d.subtract(Duration(days: d.weekday - 1));

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final regs = await DatabaseService.getRegistrosSemana(widget.nino.id!, _monday);
    setState(() {
      _registros = regs;
      _loading = false;
    });
  }

  Registro? _find(DateTime day, String hora) {
    final p = hora.split(':');
    final h = int.parse(p[0]);
    final m = int.parse(p[1]);
    final slotStart = h * 60 + m;
    final slotEnd = slotStart + 30;
    for (final r in _registros) {
      final rd = r.fecha;
      if (rd.year == day.year && rd.month == day.month && rd.day == day.day) {
        final rm = r.horaInicio.hour * 60 + r.horaInicio.minute;
        if (rm >= slotStart && rm < slotEnd) return r;
      }
    }
    return null;
  }

  void _navSemana(int offset) {
    setState(() => _monday = _monday.add(Duration(days: offset * 7)));
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yy');
    final weekDays = List.generate(5, (i) => _monday.add(Duration(days: i)));

    return Scaffold(
      appBar: AppBar(
        title: Text('Cuadrante — ${widget.nino.nombre}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Exportar PDF',
            onPressed: () async {
              await PdfService.printSemana(
                  widget.nino.nombre, widget.nino.id!, _registros);
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Week navigator
                Container(
                  color: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: Colors.white, size: 30),
                        onPressed: () => _navSemana(-1),
                      ),
                      Text(
                        'Semana del ${df.format(_monday)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: Colors.white, size: 30),
                        onPressed: () => _navSemana(1),
                      ),
                    ],
                  ),
                ),
                // Matrix
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          // Header row
                          Row(
                            children: [
                              _headerCell('Hora', isHora: true),
                              ...List.generate(5, (i) => _headerCell(
                                '${_diasLabel[i]}\n${df.format(weekDays[i])}')),
                            ],
                          ),
                          // Data rows
                          ..._horas.map((hora) => Row(
                            children: [
                              _horaCell(hora),
                              ...List.generate(5, (di) {
                                final reg = _find(weekDays[di], hora);
                                return CeldaWidget(registro: reg);
                              }),
                            ],
                          )),
                        ],
                      ),
                    ),
                  ),
                ),
                // Legend
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: const Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _LegendItem(color: AppTheme.pipiColor, label: 'Pipí'),
                      _LegendItem(color: AppTheme.cacaColor, label: 'Caca'),
                      _LegendItem(color: Colors.orange, label: 'Ambos'),
                      _StarLegend(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _headerCell(String text, {bool isHora = false}) {
    return Container(
      width: isHora ? 60 : 72,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.primary,
        border: Border.all(color: Colors.white24, width: 0.5),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _horaCell(String hora) {
    return Container(
      width: 60,
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EAF6),
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
      child: Text(
        hora,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
      ],
    );
  }
}

class _StarLegend extends StatelessWidget {
  const _StarLegend();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star, color: AppTheme.iniciativaColor, size: 16),
        SizedBox(width: 4),
        Text('Pidió ir', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
      ],
    );
  }
}