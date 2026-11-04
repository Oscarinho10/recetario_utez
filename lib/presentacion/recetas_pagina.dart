import 'package:flutter/material.dart';

import 'recetas_view_model.dart';
import 'tarjeta_receta.dart';

class RecetasPagina extends StatefulWidget {
  const RecetasPagina({super.key, required this.vm});

  final RecetasViewModel vm;

  @override
  State<RecetasPagina> createState() => _RecetasPaginaState();
}

class _RecetasPaginaState extends State<RecetasPagina> {
  final TextEditingController _controlador = TextEditingController();

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  void _buscar() {
    widget.vm.buscar(_controlador.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recetario UTEZ')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              key: const Key('busqueda'),
              controller: _controlador,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _buscar(),
              decoration: const InputDecoration(
                hintText: 'Busca una receta',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ListenableBuilder(
              listenable: widget.vm,
              builder: (context, _) => FilledButton(
                key: const Key('buscar'),
                onPressed: widget.vm.cargando ? null : _buscar,
                child: const Text('Buscar recetas'),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListenableBuilder(
                listenable: widget.vm,
                builder: (context, _) => _contenido(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contenido() {
    final estado = widget.vm.estado;

    return switch (estado) {
      RecetasInicial() => const Center(
        child: Text(
          'Escribe una receta o déjalo vacío y toca Buscar recetas.',
          textAlign: TextAlign.center,
        ),
      ),
      RecetasCargando() => const Center(child: CircularProgressIndicator()),
      RecetasVacias(:final busqueda) => Center(
        child: Text(
          busqueda.isEmpty
              ? 'No hay recetas disponibles.'
              : 'No encontramos recetas para "$busqueda".',
          textAlign: TextAlign.center,
        ),
      ),
      RecetasFallidas(:final mensaje) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(mensaje, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: widget.vm.reintentar,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
      RecetasListas(:final recetas, :final total) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mostrando ${recetas.length} de $total recetas · '
            'Rápidas: ${widget.vm.rapidas}',
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: recetas.length,
              itemBuilder: (context, indice) =>
                  TarjetaReceta(receta: recetas[indice]),
            ),
          ),
        ],
      ),
    };
  }
}
